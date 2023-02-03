#!/usr/bin/env ruby
# Requires rubygems
#
####################################################################################
##    This program is free software: you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation, either version 3 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details. <http://www.gnu.org/licenses/>
####################################################################################

ENV['MAGICK_CONFIGURE_PATH'] = '/gpfs/group/mdr23/usr/tools/etc/ImageMagick'

Font_family = 'Verdana'
SNPDefaultColor = 'black'
DefaultEthnicity = '-'
DefaultPhenotype = 'Unknown'
$color_column_included = false
#CytoBandFile = 'cytoBand.txt'
CytoBandFile = '/Users/dudeksm/Documents/lab/rails/visualization/plot/cytoBand.txt'
#CytoBandFile = '/gpfs/group1/m/mdr23/www/visualization/plot/cytoBand.txt'

begin
  require 'rubygems'
rescue LoadError => e
  puts e
  puts "Please install rubygems -- http://docs.rubygems.org/read/chapter/3 "
  exit(1)
end

# Requires RMagick (http://rmagick.rubyforge.org/)
begin
  require 'rvg/rvg'
  rescue LoadError => e
  puts
  puts e
  puts "\nPlease install RMagick -- See documentation for pheno_gram or http://rmagick.rubyforge.org/install-faq.html "
  puts
  exit(1)
end

require 'optparse'
require 'ostruct'
include Magick

Version = '1.2.1'
Name = 'pheno_gram.rb'

# check for windows and select alternate font based on OS
Font_family_style = RUBY_PLATFORM =~ /mswin/ ? "Verdana" : "Times"
Font_plot_family = RUBY_PLATFORM =~ /darwin/ ? "Verdana" : "Helvetica"

if RUBY_PLATFORM =~ /darwin/
  Font_phenotype_names = "Geneva"
elsif RUBY_PLATFORM =~ /mswin/
  Font_phenotype_names = "Verdana"
else
  Font_phenotype_names = "Helvetica"
end



#############################################################################
#
# Class Arg -- Parses the command-line arguments.
#
#############################################################################
class Arg

  def self.parse(args)
    options = OpenStruct.new
    options.input = nil
		options.genome_file = nil
    options.out_name = 'pheno_gram'
    options.imageformat = 'png'
    options.title = " "
    options.color = 'exhaustive'
    options.pheno_spacing = 'alternative'
    options.rand_seed = 7
    options.chr_only = false
    options.circle_size = 'medium'
    options.circle_outline = false
    options.highres = false
    options.transparent_lines = false
    options.thickness_mult = 1
    options.thin_lines = false
    options.big_font=false
    options.shade_inaccessible=false
		options.cytobandfile = CytoBandFile
		options.include_notes=false
		options.zoomchr = nil
		options.zoomstart = nil
		options.zoomend = nil
		options.restrict_chroms = false
		options.transverse_lines = true
    help_selected = false
    version_selected = false
    
    opts = OptionParser.new do |opts|
       opts.banner = "Usage: #{Name}.rb [options]"
      opts.on("-i [input_file]", "Input file") do |input_file|
        options.input = input_file
      end
			opts.on("-g [genome_file]", "Genome definition file"){|genome_file|options.genome_file = genome_file}
      opts.on("-o [out_name]", "Optional output name for image") do |out_name|
        options.out_name = out_name
      end
      opts.on("-t [title]", "Main title for plot (enclose in quotes)") do |title|
        options.title = title
      end
      opts.on("-C", "--chrom-only", "Plot only chromosomes with positions") do |chrom_only|
        options.chr_only = true
      end
      opts.on("-S [circle_size]", "Set phenotype circle size (small, medium, large)") do |circle_size|
        options.circle_size = circle_size
      end
      opts.on("-O", "--outline-circle", "Plot circles with black outline") do |outline_circle|
        options.circle_outline = true
      end
      opts.on("-c [color_range]", "Options are random, exhaustive (default), grayscale, web, generator,group or list") do |color_range|
        options.color = color_range
      end
			opts.on("-Z [zoom_location]", "Zoom on chromosome (7) or portion of chromsome (7:10000000-25000000)") do |zoom_location|
				unless zoom_location =~ /:/
					options.zoomchr = Arg::split_nums(zoom_location)
				else
					loc = zoom_location.split(/:/)
					options.zoomchr = Arg::split_nums(loc[0])
					positions = loc[1].split(/:|-/)
					options.zoomstart = positions[0].to_i
					options.zoomend = positions[1].to_i
				end
			end
			opts.on("-G", "--restrict-chroms", "Include only chromosomes with input data on plot"){|restrict|options.restrict_chroms=true}
			opts.on("-a", "--include-annotation", "Include any annotation on plot"){|notes|options.include_notes=true}
      opts.on("-z", "--high-res", "Set resolution to 1200 dpi") {|hres| options.highres=true}
      opts.on("-T", "--trans-lines", "Make lines on chromosome more transparent") {|trans| options.transparent_lines=true}
      opts.on("-n", "--thin-lines", "Make lines across chromosomes thinner") {|thin| options.thin_lines=true}
			opts.on("-N", "--no-lines", "Remove position lines across chromosomes"){|nolines|options.transverse_lines=false}
      opts.on("-B", "--thick-boundary", "Increase thickness of chromosome boundary") {|thick| options.thickness_mult=2}
      opts.on("-F", "--big-font", "Increase font size of labels") {|big_font| options.big_font=true}
      opts.on("-x", "--shade-chromatin", "Add cross-hatch shading to inaccessible regions of chromosomes") {|cross_hatch|options.shade_inaccessible=true}
			opts.on("-Y [cytoBand_file]", "Location of file with banding information for use with shading chromatin"){|cytoBand_file|options.cytobandfile=cytoBand_file}
      opts.on("-p [pheno_spacing]", "Options are standard or equal or proximity (default) ") do |pheno_spacing|
        options.pheno_spacing = pheno_spacing
				options.pheno_spacing = 'alternative' if options.pheno_spacing == 'proximity'
      end
      opts.on("-r [random_seed]", "Random number generator seed (default=7") do |random_seed|
        options.rand_seed = random_seed.to_i
      end
      opts.on("-f [image_type]", "Image format for output (png default).  Other options depend on ImageMagick installation.") do |image_type|
        options.imageformat = image_type
      end
      
      opts.on_tail("-h", "--help", "Show this usage statement") do
        puts opts
        help_selected = true
      end
      opts.on_tail("-v", "--version", "Show version") do
        puts "\n\tVersion: #{Version}"
        version_selected = true
      end     
    end
      
    begin
      opts.parse!(args)
    rescue => e
      puts e, "", opts
      exit(1)
    end
    
    if version_selected
      puts
      exit(0)
    end
    
    if help_selected  
      puts
      exit(0)
    end
    
    if !options.input
      help_string = opts.help
      puts "\n",help_string,"\n"
      puts "\nExamples: #{Name} -i pheno_input.txt -o new_plot -t \"New Image\"\n"
      puts "          #{Name} -i pheno_input.txt -f jpg\n"
      print "\n"
      exit(1)
    end
		
		# check for cytoband file
		if options.shade_inaccessible and !File.exist?(options.cytobandfile)
			puts "\n#{Name} (Version: #{Version})"
			puts "\nNo cytoBand file found for chromatin shading.\nUse -Y to pass location of file."
			puts "If needed, file can be downloaded from ftp://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/cytoBand.txt.gz
\n\n"
			exit(1)
		end
    
    return options
  end
	
	# splits string up to list individual values
	def self.split_nums(str)
		values = Array.new
		pcs = str.split(/,/)
		pcs.each do |p|
			nums = p.split(/-/)
			if nums.length > 1
				(nums[0].to_i..nums[1].to_i).each {|n| values << n}
			else
				values << nums[0]
			end
		end
		return values
	end
	
end


class Phenotype
  attr_accessor :name, :color, :sortnumber, :group
  
  def initialize(n,s,g)
    @name = n
    @sortnumber = s
    @group = g
  end
  
end


class PhenotypeHolder
  attr_accessor :phenonames, :maxname
  
  def initialize(params)
    @pheno_number = 1
    if params[:color]=='group'
      @colormaker = GroupColorMaker.new
		elsif params[:color]=='exhaustive' or params[:color] == 'optimized'
			@colormaker = ExhaustiveSearchColorMaker.new
		elsif params[:color]=='grayscale'
			@colormaker = GrayScaleColorMaker.new
    end
    @phenonames = Hash.new
		@maxname = 0
  end
  
  def add_phenotype(name, group)
    unless @phenonames.has_key?(name)
      pheno = Phenotype.new(name, @pheno_number, group)
      @pheno_number += 1
      @phenonames[pheno.name] = pheno
      @colormaker.add_group(group)
			@maxname = name.length unless @maxname > name.length
    end
    return @phenonames[name]
  end
  
  def get_phenotype(name)
    return @phenonames[name]
  end
  

  def set_colors
		@colormaker.set_color_num(@phenonames.length)
    @phenonames.each_value {|pheno| pheno.color = @colormaker.gen_html(pheno.group)
		}
	end
  
  def set_color(groupname)
    return @colormaker.gen_html(groupname)
  end
  
end

class Genome
  attr_accessor :chromosomes, :ethnicities
  
  def initialize
    @chromosomes = Array.new
    @ethnicities = Hash.new
    @shapefactory=ShapeFactory.new
		@max_chr_size=0
		@chrNames = Hash.new
  end
  
	def set_chroms(chroms)
		@chromosomes = chroms
		@max_chr_size=0
		@chrNames.clear
		@chromosomes.each do |chr|
			@max_chr_size=chr.size if chr.size > @max_chr_size
			@chrNames[chr.display_num.to_s]=chr
		end
	end
	
	# remove any chromosomes that have no data points
	def remove_empty
		newchroms = Array.new
		newchroms << Chromosome.new(:number=>0, :size=>0)
		new_chr_names = Hash.new
		@max_chr_size = 0
		@chromosomes.each do |chr|
			unless chr.snps.empty?
				@max_chr_size=chr.size if chr.size > @max_chr_size
				new_chr_names[chr.display_num.to_s]=chr
				newchroms << chr
			end
		end
		@chromosomes = newchroms
		@chrNames = new_chr_names
	end
	
	def remove_unwanted(keepers)
		keep = Hash.new
		keepers.each{|k|keep[k.to_s]=1}
		newchroms = Array.new
		newchroms << Chromosome.new(:number=>0, :size=>0)
		new_chr_names = Hash.new
		@max_chr_size = 0
		@chromosomes.each do |chr|
			if keep.has_key?(chr.display_num.to_s)
				@max_chr_size=chr.size if chr.size > @max_chr_size
				new_chr_names[chr.display_num.to_s]=chr
				newchroms << chr				
			end
		end
		@chromosomes = newchroms
		@chrNames = new_chr_names
	end
	
  def add_snp(params)
    shape = @shapefactory.get_shape(params[:eth])
    params[:chr].add_snp(:name=>params[:name], :pos=>params[:pos],
      :pheno=>params[:pheno], :chr=>params[:chr], :snpcolor=>params[:snpcolor], 
      :endpos=>params[:endpos], :shape=>shape, :note=>params[:note])
    @ethnicities[params[:eth]]=shape unless @ethnicities.has_key?(params[:eth])
  end
  
  def snps_per_chrom
		@chromosomes.each do |chrom|
      puts "chrom #{chrom.display_num} has #{chrom.snps.length} SNPs"
    end
  end
  
  def pos_good?(pos, chr)
    return @chromosomes[chr.to_i].pos_good?(pos)
  end
	
	def get_chrom(chrid)
		if @chrNames.has_key?(chrid.to_s)
			return @chrNames[chrid.to_s] 
		elsif chrid.to_i >=1 and chrid.to_i < @chromosomes.length
			return @chromosomes[chrid.to_i]
		else
			return nil
		end
	end
	
	def get_chrom_by_name(name)
		return @chrNames[name]
	end
  
  def get_eth_shapes
    return @shapefactory.get_phenotypes_shapes
  end
  
	def max_chrom_size
		return @max_chr_size
	end
	
	def max_in_range(chrom_nums)
		max=0
		chrom_nums.each{|n| max = @chromosomes[n].size if @chromosomes[n].size > max}
		return max
	end
	
	def chr_good?(chrnum)
    return true if @chrNames.has_key?(chrnum) 
    return true if chrnum.to_i >=1 and chrnum.to_i < @chromosomes.length
    return false
  end
	
end

class CytoBand
	attr_accessor :start, :finish, :type
	
	def initialize(params)
		@start = params[:start] || 0
		@finish = params[:finish] || 0
		@type = params[:type] || 0
	end
	
end


class Chromosome
  attr_accessor :number, :snps, :snpnames, :centromere, :size, 
    :display_num, :note_length, :cytobands, :maxphenos
  
  @@centromeres = Array.new
  @@centromeres << 0
  @@centromeres << [121535434, 124535434]
  @@centromeres << [92326171, 95326171]
  @@centromeres << [90504854, 93504854] 
  @@centromeres << [49660117, 52660117]
  @@centromeres << [46405641, 49405641]
  @@centromeres << [58830166, 61830166]
  @@centromeres << [58054331, 61054331]
  @@centromeres << [43838887, 46838887]
  @@centromeres << [47367679, 50367679]
  @@centromeres << [39254935, 42254935]
  @@centromeres << [51644205, 54644205]
  @@centromeres << [34856694, 37856694]
  @@centromeres << [16000000, 19000000]
  @@centromeres << [16000000, 19000000]
  @@centromeres << [17000000, 20000000]
  @@centromeres << [35335801, 38335801]
  @@centromeres << [22263006, 25263006]
  @@centromeres << [15460898, 18460898]
  @@centromeres << [24681782, 27681782]
  @@centromeres << [26369569, 29369569]
  @@centromeres << [11288129, 14288129]
  @@centromeres << [13000000, 16000000]
  @@centromeres << [58632012, 61632012]
  @@centromeres << [10104553, 13104553]
  
  # sizes taken from ensembl
  @@chromsize = Array.new
  @@chromsize << 0
  @@chromsize << 249239465 
  @@chromsize << 243199373
  @@chromsize << 199411731
  @@chromsize << 191252270
  @@chromsize << 180915260
  @@chromsize << 171115067
  @@chromsize << 159138663
  @@chromsize << 146364022
  @@chromsize << 141213431
  @@chromsize << 135534747
  @@chromsize << 135006516
  @@chromsize << 133851895
  @@chromsize << 115169878
  @@chromsize << 107349540
  @@chromsize << 102531392
  @@chromsize << 90354753
  @@chromsize << 81195210 
  @@chromsize << 78077248
  @@chromsize << 64705560
  @@chromsize << 63025520
  @@chromsize << 48129895
  @@chromsize << 51304566
  @@chromsize << 155270560
  @@chromsize << 59373566
	
	@@display = Array.new
  
  def self.chromsize(n)
    return @@chromsize[n]
  end
  
	def self.create_human_chroms
		@@display.clear
		(1..22).each {|i| @@display[i]=i.to_s}
		@@display[23] = 'X'
		@@display[24] = 'Y'
		
		chroms = Array.new
		chroms << Chromosome.new(:id=>0, :centromere=>[], :size=>0, :number=>0)
		(1..24).each do |num|
			chroms << Chromosome.new(:id=>@@display[num], :centromere=>@@centromeres[num],
				:size=>@@chromsize[num], :number=>num)
		end
		return chroms
	end
	
	
  def initialize(params)
    @number = params[:number]
    @display_num = params[:id]
    @snps = Hash.new
    @snpnames = Array.new
    @centromere = params[:centromere]
    @size = params[:size]
    @centromere_triangle=Array.new
		@note_length=0
		@cytobands = Array.new
		@maxphenos=0		
  end
  
  def add_snp(params)
    unless snp = @snps[params[:name]]
      snp = @snps[params[:name]] = SNP.new(params[:chr], params[:pos], params[:endpos])
      @snpnames << params[:name]
    end
		if params[:note]
			snp.note = params[:note] 
			@note_length = snp.note.length if snp.note.length > @note_length
		end
    snp.phenos << PhenoPoint.new(params[:pheno], params[:shape])
		@maxphenos = snp.phenos.length if snp.phenos.length > @maxphenos
    snp.linecolors[params[:snpcolor]]=1
  end
  
  def sort_snps!
    @snpnames.sort!{|x,y| @snps[x].pos.to_i <=> @snps[y].pos.to_i}
  end
	
	def add_cytoband(cyto)
		@cytobands << cyto
	end
  
  def pos_good?(pos)
    if pos.to_i <= @size
      return true
    else
      return false
    end
  end
  
end

class PhenoPoint
  attr_accessor :pheno, :shape
  
  def initialize(p,s)
    @pheno = p
    @shape = s
  end
end


class SNP
  attr_accessor :chrom, :pos, :phenos, :linecolors, :endpos, :note
  
  def initialize(c,p,e=nil)
    @chrom = c
    @pos = p
    e ? @endpos=e : @endpos = @pos
    @phenos = Array.new
    @linecolors = Hash.new
  end
  
end


class ColorMaker
  
  def add_group(groupname)
  end
  
  def gen_html(groupname)
    return "rgb(220,220,220)"
  end
	
	def set_color_num(nColors)
		@nColors = nColors
	end
end

class ColorRange
  attr_accessor :name, :start, :maxlum
  
  def initialize(n, st, maxl=85)
    @name = n
    @start = st
    @l_adjust=0
    @maxlum=maxl
  end
  
  def set_intervals(total_colors)
    @l_adjust = (@maxlum.to_f - @start.luminance) / (total_colors-1) if total_colors > 1
  end

  # vary the luminescence from dark to light
  def get_color
    color = @start.clone
    @start.luminance  = @start.luminance + @l_adjust
    return [color.hue, color.saturation, color.luminance]
  end
 
end

  class HSL
    attr_accessor :hue, :saturation, :luminance
    
    def initialize(hue, sat, lum)
      @hue = hue
      @saturation = sat
      @luminance = lum
    end
  end

class GroupColorMaker < ColorMaker
  
  def initialize
    @color_ranges = Array.new 
    
    @color_ranges << ColorRange.new('blue', HSL.new(67, 100, 50))
    @color_ranges << ColorRange.new('red', HSL.new(0, 100, 50))
    @color_ranges << ColorRange.new('yellow', HSL.new(17, 100, 50),90)
    @color_ranges << ColorRange.new('gray', HSL.new(0, 0, 50),95)
    @color_ranges << ColorRange.new('green', HSL.new(33.3, 100, 25))
    @color_ranges << ColorRange.new('orange', HSL.new(6.7, 100, 50))
    @color_ranges << ColorRange.new('purple', HSL.new(83.3, 100, 25))
    @color_ranges << ColorRange.new('brown', HSL.new(7.2, 70, 22),80)
    @color_ranges << ColorRange.new('pink-jeep', HSL.new(93.6, 72, 57)) 
    
    
    @curr_group=0
    @group_totals = Hash.new
    @groups = Hash.new
    @intervals_set=false    
  end
  
  def add_group(g)
    unless @groups.has_key?(g)
      @curr_group = 0 if @curr_group == @color_ranges.length
      @groups[g]=@color_ranges[@curr_group]
      @group_totals[g]=0
      @curr_group+=1
    end
    @group_totals[g]+=1
  end
  
  def set_intervals
    @groups.each_pair{|groupname, color_range| color_range.set_intervals(@group_totals[groupname])}
    @intervals_set=true
  end
  
  def gen_html(groupname)
    set_intervals unless @intervals_set
    hsl = @groups[groupname].get_color
    return "hsl(#{hsl[0]}%,#{hsl[1]}%,#{hsl[2]}%)"
  end
  
end

class ExhaustiveSearchColorMaker < ColorMaker
	
	def initialize
		@index=0
		@exhaustiveColors = ['rgb(0,0,255)','rgb(0,255,0)','rgb(255,0,0)','rgb(0,0,52)','rgb(255,0,176)','rgb(0,79,0)','rgb(255,213,0)','rgb(155,147,255)','rgb(12,255,188)','rgb(152,79,63)','rgb(0,124,144)','rgb(62,1,145)','rgb(177,198,112)','rgb(255,150,200)','rgb(254,143,57)','rgb(225,2,255)','rgb(125,0,87)','rgb(29,24,0)','rgb(225,2,82)','rgb(1,172,38)','rgb(37,242,255)','rgb(196,255,70)','rgb(139,108,0)','rgb(126,101,143)','rgb(254,184,152)','rgb(149,199,255)','rgb(8,157,118)','rgb(105,112,80)','rgb(0,98,255)','rgb(238,118,255)','rgb(165,24,0)','rgb(3,66,156)','rgb(180,255,213)','rgb(69,0,20)','rgb(255,204,105)','rgb(254,120,106)','rgb(162,255,142)','rgb(160,0,155)','rgb(180,164,167)','rgb(0,51,71)','rgb(130,172,0)','rgb(0,255,115)','rgb(2,123,192)','rgb(124,48,235)','rgb(180,99,183)','rgb(247,209,255)','rgb(82,54,0)','rgb(251,255,123)','rgb(218,65,137)','rgb(123,189,183)','rgb(0,66,43)','rgb(143,0,50)','rgb(64,8,95)','rgb(255,242,188)','rgb(94,67,69)','rgb(79,151,64)','rgb(139,83,211)','rgb(182,163,1)','rgb(176,91,121)','rgb(171,88,22)','rgb(178,153,96)','rgb(77,33,73)','rgb(94,216,0)','rgb(250,255,0)','rgb(251,92,48)','rgb(90,110,0)','rgb(13,187,224)','rgb(237,170,255)','rgb(112,211,141)','rgb(255,171,0)','rgb(109,15,0)','rgb(230,30,212)','rgb(35,221,192)','rgb(28,1,22)','rgb(255,115,211)','rgb(45,62,113)','rgb(129,169,123)','rgb(0,114,234)','rgb(255,3,59)','rgb(166,154,219)','rgb(237,141,147)','rgb(42,56,0)','rgb(105,115,124)','rgb(182,253,255)','rgb(3,216,116)','rgb(202,211,30)','rgb(106,69,143)','rgb(220,148,83)','rgb(211,79,102)','rgb(51,120,102)','rgb(254,194,202)','rgb(196,208,184)','rgb(196,144,179)','rgb(185,134,115)','rgb(255,0,130)','rgb(197,132,2)','rgb(0,0,181)','rgb(4,59,183)','rgb(199,82,255)','rgb(109,166,255)','rgb(206,255,173)','rgb(106,145,184)','rgb(67,117,63)','rgb(185,209,227)','rgb(142,100,50)','rgb(179,222,96)','rgb(133,0,181)','rgb(101,112,194)','rgb(120,39,70)','rgb(187,70,56)','rgb(155,151,54)','rgb(56,73,68)','rgb(2,92,132)','rgb(196,6,142)','rgb(113,38,147)','rgb(149,110,120)','rgb(61,24,0)','rgb(121,215,74)','rgb(97,93,30)','rgb(0,173,243)','rgb(1,72,255)','rgb(243,232,140)','rgb(0,22,122)','rgb(137,66,120)','rgb(209,120,91)','rgb(166,0,255)','rgb(193,125,239)','rgb(2,128,0)','rgb(0,160,153)','rgb(156,255,0)','rgb(255,112,0)','rgb(0,173,96)','rgb(132,152,137)','rgb(209,36,50)','rgb(77,67,40)','rgb(2,29,99)','rgb(0,36,32)','rgb(238,198,135)','rgb(240,214,75)','rgb(74,75,99)','rgb(253,220,199)','rgb(117,55,0)','rgb(210,1,8)','rgb(133,94,255)','rgb(126,138,74)','rgb(121,120,255)','rgb(255,115,158)','rgb(204,87,0)','rgb(216,72,196)','rgb(152,45,138)','rgb(121,205,169)','rgb(123,199,96)','rgb(183,217,162)','rgb(166,44,96)','rgb(207,101,162)','rgb(129,96,76)','rgb(139,224,255)','rgb(97,91,198)','rgb(180,173,208)','rgb(77,50,202)','rgb(124,255,96)','rgb(190,194,74)','rgb(106,47,46)','rgb(139,206,0)','rgb(36,34,64)','rgb(230,116,67)','rgb(199,158,63)','rgb(86,137,0)','rgb(200,175,146)','rgb(128,255,238)','rgb(5,235,55)','rgb(45,40,45)','rgb(130,255,197)','rgb(150,0,26)','rgb(181,68,209)','rgb(193,0,89)','rgb(45,27,231)','rgb(254,148,255)','rgb(255,84,100)','rgb(44,0,57)','rgb(230,255,219)','rgb(0,90,93)','rgb(252,173,68)','rgb(120,72,98)','rgb(0,130,69)','rgb(8,34,0)','rgb(134,166,179)','rgb(150,112,181)','rgb(82,102,157)','rgb(138,173,63)','rgb(169,0,221)','rgb(255,75,129)','rgb(69,31,45)','rgb(16,127,223)','rgb(162,64,78)','rgb(209,136,200)','rgb(52,198,207)','rgb(236,215,231)','rgb(111,245,157)','rgb(255,255,255)']
		@colors20 = ['rgb(255,246,255)','rgb(13,112,105)','rgb(31,22,50)','rgb(5,153,36)','rgb(255,255,0)','rgb(241,20,15)','rgb(37,183,255)','rgb(69,10,255)','rgb(22,250,228)','rgb(120,0,127)','rgb(32,115,255)','rgb(255,166,255)','rgb(255,22,254)','rgb(255,164,2)','rgb(74,255,15)','rgb(99,1,2)','rgb(123,110,29)','rgb(255,146,128)','rgb(255,31,137)','rgb(226,255,162)']
		@colors21 = ['rgb(74,0,255)','rgb(32,255,255)','rgb(9,112,7)','rgb(72,107,255)','rgb(8,255,5)','rgb(234,255,6)','rgb(255,31,255)','rgb(106,76,0)','rgb(255,161,2)','rgb(48,0,91)','rgb(251,160,255)','rgb(255,146,129)','rgb(58,173,255)','rgb(0,5,21)','rgb(80,127,119)','rgb(255,3,143)','rgb(115,0,44)','rgb(249,239,150)','rgb(255,43,19)','rgb(251,240,255)','rgb(106,255,154)']
		@colors25 = ['rgb(255,62,134)','rgb(109,78,27)','rgb(255,80,0)','rgb(37,251,255)','rgb(98,140,130)','rgb(138,192,255)','rgb(255,164,118)','rgb(150,7,21)','rgb(21,96,18)','rgb(49,13,160)','rgb(7,0,255)','rgb(255,176,214)','rgb(243,255,0)','rgb(132,37,113)','rgb(253,131,255)','rgb(5,66,121)','rgb(254,253,150)','rgb(66,127,254)','rgb(245,255,243)','rgb(255,184,13)','rgb(43,5,18)','rgb(55,255,174)','rgb(220,0,255)','rgb(112,192,41)','rgb(18,255,15)']
		@colors = @exhaustiveColors
		@final_color_index = @colors.length-1
	end
	
	def set_color_num(nColors)
			@colors = @exhaustiveColors
		@final_color_index = @colors.length-1
	end
	
	def gen_html(groupname)
		@index = 0 if @index > @final_color_index
		colorname = @colors[@index]
		@index += 1
		return colorname
  end
	
end


class GrayScaleColorMaker < ColorMaker
	
	def initialize
		@darkgray = 68
		@lightgray= 238
		@colors = Array.new
		@index = 0
	end
	
	def set_color_num(nColors)
		interval = (@lightgray-@darkgray)/(nColors-1).to_f if nColors > 1
		currcolor = @darkgray
		@colors << "'rgb(#{currcolor},#{currcolor},#{currcolor})'"
		for i in 0..nColors-1
			currcolor += interval  
		  @colors << "'rgb(#{currcolor},#{currcolor},#{currcolor})'"
		end
		@final_color_index = nColors-1
	end
	
	def gen_html(groupname)
		@index = 0 if @index > @final_color_index
		colorname = @colors[@index]
		@index += 1
		return colorname
  end
	
end

class FileHandler
  
  def close()
    @file.close
  end 
     
  # strips and splits the line
  # returns the data array that results
  def strip_and_split(line)
    line.rstrip!
    line.split(/\s/)
  end 
  
  def strip_and_split_delim(line,delim)
    line.rstrip!
    line.split(/#{delim}/)
  end 
  
end


class ChromosomeFileReader < FileHandler
	
	def initialize
		@idcol = 0
		@sizecol  = 1
		@centcol = nil
	end
	
	def open(filename)
		@file = File.new(filename, "r")
	end

	def parse_file(filename)
		chroms = Array.new
		chroms << Chromosome.new(:number=>0, :size=>0)
		number=1
		firstline = true
		open(filename)
			headers = nil
	    while oline=@file.gets
      oline.each_line("\r") do |line|
				if firstline
					headers = read_headers(line)
					firstline = false
					next
				end
				next unless line =~ /\d/
				cols = strip_and_split_delim(line, "\t")
				cent_array = Array.new
				if !@centcol.nil?
					if !cols[@centcol].nil?
						cent_array = cols[@centcol].split(",")
					end
				end
				centromere_info = cent_array.collect{|s| s.to_i}
				chroms << Chromosome.new(:id=>cols[@idcol], :centromere=>centromere_info,
					:size=>cols[@sizecol].to_i, :number=>number)
				number += 1
			end
			end
		close
		return chroms
	end
	
	def read_headers(oline)
		oline.each_line("\r") do |line|
			cols = strip_and_split_delim(line, "\t")
			cols.each_with_index do |c,i|
				if c =~ /id/i
					@idcol = i
				elsif c =~ /size/i
					@sizecol  = i
				elsif c =~ /centro/i
					@centcol = i
				end
			end
		end
	end
	
end


class CytoBandFileReader < FileHandler
	
	def open(filename)
		@file = File.new(filename, "r")
	end
	
	def parse_file(filename, genome)
		open(filename)
			headerline = @file.gets
			set_columns(headerline)
	    while oline=@file.gets
      oline.each_line("\r") do |line|
				next unless line =~ /\w/
				cols = strip_and_split_delim(line, "\t")
				cols[@chromcol] =~ /^chr(\w+)/
				if $1
					chromstr = $1;
				else
					chromstr = cols[@chromcol]
				end
				if cols[@endcol].to_i <= cols[@startcol].to_i
					next
				elsif cols[@startcol].to_i == 0
						cols[@startcol] = 1
				end
				cyto = CytoBand.new(:start=>cols[@startcol].to_i, :finish=>cols[@endcol].to_i, :type=>cols[@giecol])
				genome.get_chrom(chromstr).add_cytoband(cyto)
			end
    end	
	end
	
  def set_columns(headerline)
		@chromcol = @startcol = @endcol = @giecol = nil
		headers = strip_and_split_delim(headerline, "\t")
		headers.each_with_index do |header,i|
			if header =~ /#chrom/i
				@chromcol = i
			elsif header =~ /chromStart/i
				@startcol = i
			elsif header =~ /chromEnd/i
				@endcol = i
			elsif header =~ /gieStain/i
				@giecol = i
			end
		end
		
		unless @chromcol and @startcol and @endcol and @giecol
			error_string = 'Cytoband input file must include #chrom, chromStart, chromEnd, gieStain columns'
      raise error_string
    end
  end	
	
end


class PhenoGramFileReader < FileHandler

  def open(filename)
    @file = File.new(filename, "r")
    @snpcolors = ['black','blue','red','green','orange','purple','pink', 'gold']
  end
  
  def set_columns(headerline, chr_only)
    @snpcol = @chromcol = @bpcol = @phenocol = @snpcolorcol = @bpendcol = nil
    headers = strip_and_split_delim(headerline, "\t")
    
    headers.each_with_index do |header, i|
      if header =~ /^snp$|^snp_id$/i
        @snpcol = i
      elsif header =~ /^chrom|^chr$/i
        @chromcol = i
      elsif header =~ /poscolor|snpcolor/i
        @snpcolorcol = i
        $color_column_included = true
      elsif header =~ /^bp|^pos|^start/i
        @bpcol = i
      elsif header =~ /^end/i
        @bpendcol = i
      elsif header =~ /^pheno/i
        @phenocol = i
      elsif header =~ /^colorgroup$/i
        @groupcol = i
      elsif header =~ /^race|^ethnic|^ancestry|^group/i
        @ethcol = i
			elsif header =~ /^annotation|^note/i
				@notecol = i
      end
    end

    unless @chromcol and @bpcol and (@phenocol || chr_only)
			error_string = 'Input file must include chrom, pos'
			error_string = error_string + ' and phenotype' unless chr_only
			error_string = error_string + ' columns'
      raise error_string
    end
  end
  
  def parse_file(filename, genome, phenoholder, params)
		chr_only = params[:chr_only] || false
		if(params[:zoomchr])
			included_chroms = Hash.new
			params[:zoomchr].each {|name| included_chroms[name.to_s]=1}
		end
    open(filename)
    lines = Array.new
    # read in all lines and split to accommodate Mac files
    while oline=@file.gets
      oline.each_line("\r") {|line| lines << line}
    end
    close
    
    set_columns(lines.shift, chr_only)
    group = 'default'
		lineno = 1
    lines.each do |line|
			lineno += 1
      next unless line =~ /\w/
      data = strip_and_split_delim(line,"\t")
      # add SNP info 
      next if data[@chromcol] =~ /chrM/
			
			chromosome = genome.get_chrom(data[@chromcol])
      raise "Problem in #{filename} with line:\n#{line}\n#{data[@chromcol]} is not a valid chromosome number" unless chromosome
			unless(chromosome.pos_good?(data[@bpcol]))
				print "#{filename}: line ##{lineno} pos: #{data[@bpcol]} is outside chr #{data[@chromcol]} boundaries\n";
				next
			end

      group = data[@groupcol] if @groupcol
			@phenocol ? phenotype = data[@phenocol] : phenotype = DefaultPhenotype

      @snpcol ? name = data[@snpcol] : name = data[@chromcol] + "." + data[@bpcol]
      @snpcolorcol ? snpcolor = @snpcolors[data[@snpcolorcol].to_i] : snpcolor = SNPDefaultColor
      @bpendcol ? endbp = data[@bpendcol].to_i :  endbp = data[@bpcol].to_i
      @ethcol ? ethnicity = data[@ethcol] : ethnicity = DefaultEthnicity
			if @notecol
				notecol = data[@notecol] if @notecol
				raise "Problem in #{filename} with line:\n#{line}\nAnnotation may be no longer than 10 characters in length" if notecol and notecol.length > 10
			end
			if(!params[:zoomchr] or (included_chroms.has_key?(chromosome.display_num)  and 
							(!params[:zoomstart] or (data[@bpcol].to_i >= params[:zoomstart] and endbp <= params[:zoomend]))))
				pheno = phenoholder.add_phenotype(phenotype, group)
				genome.add_snp(:name => name, :chr=>chromosome, :pos=>data[@bpcol].to_i,
					:pheno=>pheno, :snpcolor=>snpcolor, :endpos=>endbp, :eth=>ethnicity, 
					:note=>notecol)
			end
    end  
    phenoholder.set_colors
  end 
end

class Plotter
  @@circle_size=0
  @@maxchrom=0
  @@drawn_circle_size=0
	@@circle_multiplier=1
  
  def self.set_circle(n, params)
    @@circle_size = n
		size = params[:size]
		if size == 'large'
			@@drawn_circle_size =@@circle_size*2
			@@circle_multiplier = 2.0
		elsif size == 'small'
			@@drawn_circle_size =@@circle_size/2
			@@circle_multiplier = 0.5
		else # medium (default)
			@@drawn_circle_size = @@circle_size
			@@circle_multiplier = 1.0
		end
  end
  
	def self.get_circle_multiplier
		return @@circle_multiplier
	end
	
	def self.get_drawn_size
		return @@drawn_circle_size
	end
	
  def self.set_maxchrom(n)
    @@maxchrom=n
  end
  
end


class Circle
  attr_accessor :x, :y, :color
  def initialize(x,y,col)
    @x = x
    @y = y
    @color = color
  end
end


class ShapeFactory
  
  def initialize
    @shapes = Hash.new
    @shapecounter=1
  end
  
  def get_shape(name)    
    unless @shapes.has_key?(name)
      @shapes[name] = create_shape(@shapecounter)
      @shapecounter+=1  
    end

    return @shapes[name]
  end
  
  def get_phenotypes_shapes
    return @shapes
  end
  
  def create_shape(shapenum)
    case shapenum
    when 1
      return PhenoCircle.new
    when 2
      return PhenoDiamond.new
    when 3
      return PhenoTriangle.new
		when 4
			return PhenoSquare.new
    else
      return PhenoCircle.new
    end  
  end
end


class PhenoShape
  
  def draw(pen,size,x,y,color,circle_outline)
    # base class
  end
  
end

class PhenoCircle < PhenoShape
  
  def draw(pen,size,x,y,color,circle_outline)
    pen.circle(size.to_f/2, x, y).styles(:fill=>color, :stroke=>circle_outline)
  end
  
end

class PhenoDiamond < PhenoShape
  
  def draw(pen,size,x,y,color,circle_outline)
    
    offset = size.to_f/2
    
    pts = Array.new
    pts << x
    pts << y-offset
    pts << x+offset
    pts << y
    pts << x
    pts << y+offset
    pts << x-offset
    pts << y
    
    pen.polygon(pts).styles(:fill=>color, :stroke=>circle_outline)
  end
  
end
  
class PhenoSquare < PhenoShape
  
  def draw(pen,size,x,y,color,circle_outline)
    offset = size.to_f/2
    xpt = x-offset
    ypt = y-offset
    height=width=size
    pen.rect(height,width,xpt,ypt).styles(:fill=>color, :stroke=>circle_outline)
  end
  
end

 class PhenoTriangle < PhenoShape
   
   def draw(pen,size,x,y,color,circle_outline)
     offset = size.to_f/2
     pts = Array.new
     pts << x
     pts << y-offset
     pts << x+offset
     pts << y+offset
     pts << x-offset
     pts << y+offset
     
     pen.polygon(pts).styles(:fill=>color, :stroke=>circle_outline)
   end
  
end



class PhenoBox < Plotter
  attr_accessor :top_y, :bottom_y, :circles, :phenocolors, :chrom_y, :height, 
    :up, :line_colors, :chrom_end_y, :endpos, :phenoshapes, :note
  @@circles_per_row = 0
  
  def self.set_circles_per_row(c)
    @@circles_per_row = c
  end
  
  def initialize
    @circles = Array.new
    @phenocolors = Array.new
    @phenoshapes = Array.new
    @up = true
    @line_colors = Array.new
  end
  
  def add_circle(x,y,color)
    @circles << Circle.new(x,y,color)
  end
  
  def add_phenocolor(p)
    @phenocolors << p
  end
  
  def add_shape(s)
    @phenoshapes << s
  end
  
  def add_line_color(color)
    @line_colors << color
  end
  
  def estimate_height
    return (@phenocolors.length.to_f/@@circles_per_row).ceil * @@drawn_circle_size
  end
  
  def set_default_boundaries(center, end_y)
    @chrom_y = center
    @chrom_end_y = end_y
    
    if @up
      adjust = -@@drawn_circle_size
    else
      adjust = @@drawn_circle_size
    end
    
    @top_y = center+adjust.to_f/4
    if @phenocolors.length <= @@circles_per_row
      @bottom_y = @top_y + @@drawn_circle_size
    else # each row will overlap by 1/4 of a circle on one above
      @bottom_y = @top_y + @@drawn_circle_size + @@drawn_circle_size * 0.75 * @phenocolors.length/@@circles_per_row
    end
    @height = @bottom_y - @top_y 
  end

  def set_even_boundaries(chrom_y, y, chrom_end_y)
    @chrom_y = chrom_y
    @chrom_end_y = chrom_end_y
    @top_y = y
    if @phenocolors.length <= @@circles_per_row
      @bottom_y = @top_y + @@drawn_circle_size
    else # each row will overlap by 1/4 of a circle on one above
      @bottom_y = @top_y + @@drawn_circle_size + @@drawn_circle_size * 0.75 * @phenocolors.length/@@circles_per_row
    end   
    @height = @bottom_y - @top_y
  end
  
  # set the top and bottom location
  # top is simply halfway above first row
  def set_boundaries(center)
    @chrom_y = center
    @top_y = center#+adjust.to_f/4
    if @phenocolors.length <= @@circles_per_row
      @bottom_y = @top_y + @@drawn_circle_size
    else # each row will overlap by 1/4 of a circle on one above
      @bottom_y = @top_y + @@drawn_circle_size + @@drawn_circle_size * 0.75 * @phenocolors.length/@@circles_per_row
    end
    @height = @bottom_y - @top_y
  end
  
end


class PhenoBin
  attr_accessor :actual_height,:height_needed, :starty, :endy, :boxes,
    :startbase, :endbase, :boxpos
  
  def initialize
    @actual_height=@height_needed=@starty=@endy=0
    @boxes = Array.new
    @boxpos = Hash.new
  end
  
  def calc_height_needed
    @height_needed=0
    @boxpos.each_value{|box| @height_needed+=box.height}
    return @height_needed
  end
  
  def estimate_height
    estimate_total=0
    @boxpos.each_value{|box| estimate_total+=box.estimate_height}
    return estimate_total  
  end
  
  def sort_boxes!
    @boxes.sort!{|x,y| x.to_i <=> y.to_i} 
  end
  
  def height_discrepancy
    return @actual_height-@height_needed
  end
  
  def add_phenotype_snp(pos, endpos, col, shape, note=nil)
    if @boxpos.has_key?(pos)
      pbox = @boxpos[pos]
    else
      pbox = PhenoBox.new
      pbox.endpos = endpos
      @boxpos[pos]=pbox
      @boxes << pos
    end
    
    pbox.add_phenocolor(col)
    pbox.add_shape(shape)
		pbox.note = note if note
  end
  
  def add_linecolors(pos,linecolors)
    pbox = @boxpos[pos]
    linecolors.each{|color| pbox.add_line_color(color)}
  end
  
  def bp_from_y(y)
    return y/@actual_height.to_f * (@endbase-@startbase) + @startbase
  end
  
  def y_from_bp(bp)
    return (bp.to_f-@startbase)/(@endbase-@starbase) * @actual_height
  end
  
  def set_phenobox_y
    @height_needed=0
    @boxpos.each_pair do |pos, phenobox|
      ycenter = (pos.to_i-@startbase)/(@endbase-@startbase).to_f * @actual_height
      @height_needed += phenobox.set_boundaries(ycenter)
    end
  end
end

# contains the phenoboxes
class PhenoBinHolder
  attr_accessor :phenobins, :totalchromy, :totalbases, :totaly, :startbases
  
  def initialize
    @phenobins = Array.new
  end
 
  def set_num_bins(n)
    n.times do |i|
     @phenobins << PhenoBin.new
     @phenobins.last.actual_height = totaly.to_f/n
    end
  end
  
  # set base intervals for the bins
  def set_bases
    height=0
    y=0
    
    y_interval = @totaly.to_f/@phenobins.length
    curr_y = 0
    base_interval = @totalbases.to_f/@phenobins.length
    currbase=0   
    @phenobins.each do |pb|
      pb.starty = curr_y
      pb.startbase = currbase
      currbase += base_interval
      curr_y += y_interval
      pb.endy = curr_y
      pb.endbase = currbase
      pb.actual_height = pb.endy-pb.starty
    end   
    
  end
  
  def get_box_array(y_from_top, chrom_size, total_chrom_y)
    final_phenoboxes = Array.new
    bin_y = y_from_top
    @phenobins.each do |pbin|
      phenoboxes = Array.new
      boxes_total = 0
      pbin.boxpos.each_pair do |pos, phenobox|
        phenobox.top_y = bin_y + phenobox.top_y
        phenobox.bottom_y = bin_y + phenobox.bottom_y
        phenobox.chrom_y = pos.to_f / chrom_size * total_chrom_y
        phenobox.chrom_end_y = phenobox.endpos.to_f / chrom_size * total_chrom_y
        phenoboxes << phenobox
        boxes_total +=1
      end
      
      phenoboxes.sort!{|x,y| x.top_y <=> y.top_y}
      
      # spread out phenoboxes throughout the bin if any collisions
      # if too many boxes for bin just arrange along as spread out as possible
      # if space and collisions again just spread out
      # if space and no collisions don't change top_y, bottom_y
      spread_boxes = false
      if pbin.height_needed > pbin.actual_height
        spread_boxes = true
      else
        j=phenoboxes.length-1
        for i in 1..j
          if phenoboxes[i].top_y < phenoboxes[i-1].bottom_y
            spread_boxes=true
            break
          end
        end
      end
      
      if spread_boxes
        y_spread = pbin.actual_height / boxes_total.to_f
        phenoboxes.clear
        y_pos = 0
        pbin.boxpos.each_pair do |pos, phenobox|
          phenobox.top_y = bin_y + y_pos
          phenobox.bottom_y = bin_y + (phenobox.bottom_y - phenobox.top_y) + y_pos
          phenobox.chrom_y = pos.to_f / chrom_size * total_chrom_y
          phenobox.chrom_end_y = phenobox.endpos.to_f / chrom_size * total_chrom_y
          y_pos += y_spread
          phenoboxes << phenobox
        end      
      end
      
      bin_y += pbin.actual_height
      final_phenoboxes.push(*phenoboxes)
    end
    return final_phenoboxes
  end
  
  # adds a phenotype to appropriate bin
  def add_phenotype_snp(position, endpos, color, linecolors, shape, note)
    @phenobins.each do |pb|
      if position.to_i >= pb.startbase and position.to_i < pb.endbase
        pb.add_phenotype_snp(position, endpos, color, shape, note)
        return pb
      end
    end
  end
  
  def set_pheno_positions
    @phenobins.each do |pb|
      pb.set_phenobox_y
    end
  end
  
  
  def show_bin_info
    @phenobins.each do |pb|
      puts "bin endy=#{pb.endy} startbase=#{pb.startbase} endbase=#{pb.endbase} actual_height=#{pb.actual_height}"
      pb.boxpos.each do |pos, box|
        puts "box pos=#{pos} topy=#{box.top_y} bottomy=#{box.bottom_y}"
      end
      puts "---- END BIN ----"
    end 
  end
  
  # for each phenotype adjust its placement 
  # relative to its enclosing bin
  def adjust_phenos
    i=0
    @phenobins.each do |pb|
      y_span = pb.endy-pb.starty
      bp_span = pb.endbase - pb.startbase
      pb.boxes.each do |pos|
        box=pb.boxpos[pos]
        y_center = (pos.to_i-pb.startbase)/bp_span.to_f * y_span
        box.set_boundaries(y_center)
      end
      i+=1
    end
  end
 
  # change the bp represented in a bin if it the top
  # and bottom boxes have additional space and
  # there isn't enough room to fit all the phenotype boxes
  # contained in it
  def adjust_bp
    @phenobins.each_with_index do |pbin, i|
      pbin.calc_height_needed
      
      pbin.sort_boxes!
      
      # do nothing when the bin has enough space for its phenotypes
      # no need to change the bp spread    
      if pbin.actual_height <= pbin.height_needed or pbin.boxes.empty?
        next
      end
      
      topbp = pbin.startbase
      bottombp = pbin.endbase  
      alter_top = alter_bottom = false
      
      # first check top y on first box to see if it is within the bin
      if pbin.boxpos[pbin.boxes.first].top_y > 0
        topbp = pbin.bp_from_y(pbin.boxpos[pbin.boxes.first].top_y)
        alter_top=true
      end
      if pbin.boxpos[pbin.boxes.last].bottom_y < pbin.actual_height
        #bottombp = pbin.boxes.last
        bottombp = pbin.bp_from_y(pbin.boxpos[pbin.boxes.last].bottom_y)
        alter_bottom=true
      end
      
      # adjust for change in ratio
      #fract_adjust = (bottombp-topbp)/(pbin.endbase-pbin.startbase).to_f
      
      if alter_top
        pbin.startbase = topbp
      end
      if alter_bottom
        pbin.endbase = bottombp
      end
      
      # reposition phenotype boxes if any change in top or bottom
      if alter_top or alter_bottom
        pbin.set_phenobox_y
      end
    end
    
  end
  
  
  
  # place box in appropriate bin based on chromosome y value
  def add_pheno_box(box)
    # integer division works here
    index = box.chromy / @totalchromy
    @phenobins[index] << box
  end
  
  def estimate_height_needed
     total_height = 0
    @phenobins.each do |b|
      total_height+=b.estimate_height
    end
    return total_height
  end
  
  def calculate_total_height
    total_height = 0
    @phenobins.each do |b|
      total_height+=b.actual_height
    end
    return total_height
  end
  
  def calculate_height_needed
     total_height_needed = 0
    @phenobins.each do |b|
      total_height_needed+=b.calc_height_needed
    end
    return total_height_needed   
  end
  
  def total_bins   
    total_height = calculate_total_height
    small_bins = Array.new
    large_bins = Array.new
    
    total_deficit=total_excess=0
    
    # determine bins with too little height
    @phenobins.each_with_index do |b,i|
      if b.height_discrepancy < 0
        small_bins << i
        total_deficit -= b.height_discrepancy
      else
        large_bins << i
        total_excess += b.height_discrepancy
      end
    end
    
    # when all bins are large enough return or if no bins have extra 
    # space 
    if small_bins.empty? or large_bins.empty?
      return 
    end
    if total_deficit > total_excess
      fraction = 1.0
    else
      fraction = total_deficit/total_excess.to_f
    end

    released_height = total_excess * fraction

    # shrink any bins that are too large 
    large_bins.each do |i|
      # take all excess size when needed
      # only take fraction that is needed to make up deficit
      remove_amount = (@phenobins[i].height_discrepancy.to_f/total_excess) * released_height
        @phenobins[i].actual_height -= (@phenobins[i].height_discrepancy.to_f/total_excess) * released_height
    end
    
    # add height to the bins that are too small (add it proportionately 
    # based on the size needed)
    small_bins.each do |i|
      add_amount = (-@phenobins[i].height_discrepancy.to_f/total_deficit) * released_height
      @phenobins[i].actual_height += (-@phenobins[i].height_discrepancy.to_f/total_deficit) * released_height
    end
   
    curr_y=0
    phenobins.each_with_index do |pb,i|
      pb.starty = curr_y
      pb.endy = curr_y + pb.actual_height
      curr_y = pb.endy
    end
  end
 
	
  def add_chrom(chrom)
		chrom.snpnames.each do |snpname|
			snp = chrom.snps[snpname]
      pb=nil
			snp_pos = snp.pos-@startbases
			end_pos = snp.endpos-@startbases
      snp.phenos.each do |phenopt|
        pb=add_phenotype_snp(snp_pos, end_pos, phenopt.pheno.color, 
					snp.linecolors.keys, phenopt.shape, snp.note)
      end
      pb.add_linecolors(snp_pos, snp.linecolors.keys)
    end
  end

end

class Chromline
  attr_accessor :colors
  
  def initialize
    @colors = Hash.new
  end
  
  def add_line(col)
    @colors.has_key?(col) ? @colors[col] += 1 : @colors[col] = 1
  end
  
end

class ChromLineHolder
  attr_accessor :chromlines, :colors, :opacity
  
  def initialize(total_y, chromsize, opacity)
    @size = chromsize
    @chromlines = Array.new(total_y.ceil+1){|index| Chromline.new}
    @colors = Hash.new
    @opacity = opacity
  end
  
  # position is relative to start of chromosome
  def add_line(ypos, params)
    color = params[:stroke] || 'black'
    @chromlines[ypos.round].add_line(color)
    @colors[color]=1
  end
  
  def draw_lines(params)
    xbase = params[:xstart]
    ybase = params[:ystart]
    canvas = params[:canvas]
    chrom_width = params[:chrom_width]
    
    @colors.each_key do |color|
      start_index = -1
      last_value = -1
      currvalue =0
			
      @chromlines.each_with_index do |chromline, i|
        chromline.colors.has_key?(color) ? currvalue= @opacity + ((chromline.colors[color]-1) * @opacity * 0.15): currvalue = 0
        currvalue = 1.0 if currvalue > 1 # have to consider opacity when calculating values of objects
        if currvalue != last_value
          # draw last region when needed
          if last_value != -1
            canvas.g.translate(xbase,ybase) do |draw|
            # draw it (box or line if only previous index)
              if start_index == i-1 #and start_index < 50
                draw.line(0,start_index,chrom_width,start_index).styles(:stroke=>color, 
                  :stroke_width=>1, :stroke_opacity=>last_value)
              else
                end_index = i-start_index+start_index-1
                draw.rect(chrom_width, end_index-start_index,0, start_index).styles(:stroke=>color, 
                  :stroke_width=>1, :stroke_opacity=>last_value, :fill_opacity=>last_value, :fill=>color)
              end
            end
            # set last_value = -1 and start_index = -1 to mark no valid object to draw
            start_index = -1
            last_value = -1
          end
          if currvalue > 0
            last_value = currvalue
            start_index = i
          end
        end
      end
			if currvalue > 0 and start_index != -1
				canvas.g.translate(xbase,ybase) do |draw|
        # draw it (box or line if only previous index)
        if start_index == @chromlines.length-1 #and start_index < 50
					draw.line(0,start_index,chrom_width,start_index).styles(:stroke=>color, 
						:stroke_width=>1, :stroke_opacity=>last_value)
          else
             end_index = @chromlines.length-1
             draw.rect(chrom_width, end_index-start_index,0, start_index).styles(:stroke=>color, 
								:stroke_width=>1, :stroke_opacity=>last_value, :fill_opacity=>last_value, :fill=>color)
          end					
				end
			end
			
    end

  end
  
end


class ChromosomePlotter < Plotter
  @@chrom_width = 0
  @@drawn_circles_per_row=@@num_phenos_row = 6
  @@circle_outline = 'black'
  
  def self.set_chrom_width(w)
    @@chrom_width = w
  end
  
  def self.set_circle_outline(color)
    @@circle_outline=color
  end
  
	def self.calc_chr_per_row(total_num_chromosomes)
		# want fewest rows for the smallest number in a row
		# then largest value for that number of rows
		fewest_rows = 100000
		min = 6
		max = 12
		for i in min..max
			val = total_num_chromosomes.to_f/i
			fewest_rows = val.to_i if val.to_i < fewest_rows
		end
		number_to_use = 0
		for i in (min..max).to_a.reverse
			val = total_num_chromosomes.to_f/i
			if val == fewest_rows
				number_to_use = i
				break
			end
			number_to_use = i if val.to_i == fewest_rows
		end
		return number_to_use
	end
	
  def self.set_phenos_row(p, params)
    @@num_phenos_row = p
		size = params[:size]
		if size == 'large'
			@@drawn_circles_per_row = p/2
		elsif size == 'small'
			@@drawn_circles_per_row = p*2-1
		else # medium
			@@drawn_circles_per_row = p
		end
    PhenoBox.set_circles_per_row(@@drawn_circles_per_row)
  end
  
  def self.init_phenobinholder(params)
    binholder = PhenoBinHolder.new
    binholder.totalchromy = params[:chrom_y]
    binholder.totaly = params[:available_y]
    binholder.totalbases = params[:chrom_size]
		binholder.startbases = params[:chrom_start]
    binholder.set_num_bins(5)
    binholder.set_bases
    return binholder
  end
  
	def self.set_cyto_colors
		@@cytocolors = Hash.new
		@@cytocolors['gneg'] = 'white'
		# grays from http://www.j-a-b.net/web/hue/color-grayscale.phtml
		@@cytocolors['gpos25'] = '#ECECEC'
		@@cytocolors['gpos33'] = '#E1E1E1'
		@@cytocolors['gpos50'] = '#C7C7C7'
		@@cytocolors['gpos66'] = '#AFAFAF'
		@@cytocolors['gpos75'] = '#9F9F9F'
		@@cytocolors['gpos100'] = '#787878'
		@@cytocolors['stalk'] = '#63B8FF'
		@@cytocolors['gvar'] = '#4F94CD'
		@@cytocolors['acen'] = '#0000A0'
		@@cytocolors['gpos'] = '#C7C7C7'
		
	end
	
    # utilizes new algorithm to place boxes
  # maintains relative location along chromosome
  def self.position_phenoboxes(params)
    
    absolutey=totaly = params[:available_y]
    totalchromy = params[:chrom_y]
    chrom = params[:chrom]
		chrom.sort_snps!
		chrom_size = params[:chrom_size]
		chrom_start = params[:chrom_start] || 0
   
    binholder=init_phenobinholder(params)
    # add phenotypes to the bins
    binholder.add_chrom(chrom)

    # check to see if can shrink the plotting area to the chromosome only
    orig_phenobox_offset = phenobox_offset = -((totaly-totalchromy.to_f)/2)
    estimated_tot=binholder.estimate_height_needed

    if estimated_tot < totalchromy
      params[:available_y] = params[:chrom_y]
      binholder=init_phenobinholder(params)
      totaly = totalchromy
      binholder.add_chrom(chrom)
      phenobox_offset = 0
    elsif estimated_tot < totaly
      adjustedy = estimated_tot
      params[:available_y] = adjustedy
      binholder=init_phenobinholder(params)
      totaly = adjustedy
      binholder.add_chrom(chrom)
      phenobox_offset = (totalchromy-estimated_tot.to_f)/2        
    end
    binholder.set_pheno_positions
    # adjust size of bins
    binholder.total_bins 
    # remap the phenotypes to the bins
    binholder.adjust_phenos
    # change bp on bins so top of bin in bp matches first pheno/
    # and bottom of bin in bp matches last pheno
    binholder.adjust_bp
    # place phenoboxes in an array with locations relative to 
    # the absolute base position
    phenoboxes = binholder.get_box_array(phenobox_offset,chrom_size,totalchromy)
    
    return phenoboxes if phenoboxes.empty? 
    return phenoboxes
  end


  # move the boxes for collisions
  def self.adjust_collisions(phenoboxes, available_y, offset)
    total_boxes = phenoboxes.length
    last_index = total_boxes-1
    notdone = true
    rounds=0

    while(notdone and rounds < 7)
      notdone = false
      for i in (0..last_index)
        for j in (i+1..last_index)
          if phenoboxes[i].bottom_y > phenoboxes[j].top_y
            move_boxes(phenoboxes, available_y, i, j, offset)
            notdone=true
          end
        end
      end
      rounds += 1
    end 
  end
  
  
  def self.shift_boxes(phenoboxes, i, moveup)
    if moveup
      if phenoboxes[i+1].top_y > (phenoboxes[i].bottom_y-phenoboxes[i].height)
        phenoboxes[i].bottom_y = phenoboxes[i+1].top_y
        phenoboxes[i].top_y = phenoboxes[i].bottom_y - phenoboxes[i].height
      else
        phenoboxes[i].top_y -= phenoboxes[i].height
        phenoboxes[i].bottom_y -= phenoboxes[i].height
      end
    else
       if phenoboxes[i-1].bottom_y < (phenoboxes[i].top_y+phenoboxes[i].height)
         phenoboxes[i].top_y = phenoboxes[i-1].bottom_y
         phenoboxes[i].bottom_y = phenoboxes[i].top_y+phenoboxes[i].height
       else
        phenoboxes[i].bottom_y += phenoboxes[i].height
        phenoboxes[i].top_y += phenoboxes[i].height
       end
    end
    
  end
  
  
  def self.move_boxes(phenoboxes, available_y, i, j, offset)
    last_index = phenoboxes.length-1
    # check for room on top and bottom 
    toproom=bottomroom=false
    if (i==0 or (phenoboxes[i].top_y - phenoboxes[i].height > phenoboxes[i-1].bottom_y)) and
        phenoboxes[0].top_y > offset
      toproom=true
    end
    if (j==last_index or (phenoboxes[j].bottom_y+phenoboxes[j].height < phenoboxes[j].top_y)) and
        phenoboxes.last.top_y < available_y + offset
      bottomroom=true
    end
    # move in direction with more space available
    # use xor to move in direction when only one available
    # when both are ok or neither is, move in direction of more available space
    if (toproom and bottomroom)# or (!toproom and !bottomroom)
      topdist = (phenoboxes[i].top_y.to_f - offset) / i
      bottomdist = (available_y.to_f - phenoboxes[j].bottom_y-offset)/(last_index-j)
      if topdist > bottomdist
        shift_boxes(phenoboxes,i,true)
      else
        shift_boxes(phenoboxes,j,false)
      end
    elsif toproom
      # shift top box up
      shift_boxes(phenoboxes, i, true)
    elsif bottomroom
      # shift lower box down
      shift_boxes(phenoboxes, j, false)
    end   
    # when no room do nothing
  end
  
  
  def self.plot_chrom(params)
   
    padding = @@circle_size*2
    # leave some space at top and bottom
    available_y = params[:height]-padding
    
    chrom = params[:chrom]
		chrom_start = params[:zoomstart]|| 0
		params[:zoomstart] ? chrom_size = params[:zoomend]-params[:zoomstart] : chrom_size = chrom.size.to_f
		
    # determine location of the chromosome -- leave a circle at top and bottom
    total_chrom_y = chrom_size/ @@maxchrom * available_y
    # create a number of bins to hold information for each possible line
    unless $color_column_included
      params[:transparent] ? opacity = 0.05 : opacity = 1.0
    else
      params[:transparent] ? opacity = 0.35 : opacity = 1.0
    end

    line_container = ChromLineHolder.new(total_chrom_y.ceil, chrom_size, opacity)
    
    start_chrom_y = padding.to_f/2 + (available_y-total_chrom_y).to_f/2
    end_chrom_y = start_chrom_y + total_chrom_y
    
    canvas = params[:canvas]
    xbase = params[:xstart]
    ybase = params[:ystart]

    #circle_start_x = @@circle_size*3   
		circle_start_x = @@chrom_width + @@circle_size*1.5
		circle_start_x += @@circle_size * 4 if params[:zoomchr]
		centromere_pos = chrom.centromere 
		unless(centromere_pos.empty? or (params[:zoomstart] and (centromere_pos[0] < params[:zoomstart] or 
					centromere_pos[1] > params[:zoomend])))
			centromere_y = total_chrom_y * ((((centromere_pos[0]+centromere_pos[1])/2)-chrom_start)/chrom_size.to_f) + start_chrom_y
			centromere_start = total_chrom_y * ((centromere_pos[0]-chrom_start)/chrom_size.to_f) + start_chrom_y
			centromere_end = total_chrom_y * ((centromere_pos[1]-chrom_start)/chrom_size.to_f) + start_chrom_y
		end
		
		params[:zoomstart] ? startbp = params[:zoomstart] : startbp = 0
		params[:zoomend] ? endbp = params[:zoomend] : endbp = chrom.size
	
    draw_chr(:canvas=>canvas, :centromere_y=>centromere_y, :start_chrom_y=>start_chrom_y, 
      :end_chrom_y=>end_chrom_y, :xbase=>xbase, :ybase=>ybase, :chromnum=>chrom.display_num,
      :thickness_mult=>params[:thickness_mult], :chr_only=>params[:chr_only], 
      :bigtext=>params[:bigtext], :cent_start=>centromere_start, :cent_end=>centromere_end,
      :shade=>params[:shade], :startbp=>startbp, :endbp=>endbp, 
			:chrom_start=>chrom_start, :chrom_bp=>chrom_size, :chrom=>chrom,
			:increase_cyto_opacity=>!params[:draw_transverse])
		
		
    if params[:chr_only] or !(params[:alt_spacing]==:alternative or params[:alt_spacing]==:equal)
      phenoboxes = get_pheno_boxes(total_chrom_y, chrom, chrom_size, chrom_start)
      phenoboxes.sort!{|x,y| x.top_y <=> y.top_y}
      phenoboxes.each do |box|
        draw_phenos(canvas, box, circle_start_x, xbase, ybase + start_chrom_y, line_container,
          :chr_only=>params[:chr_only], :transparent=>params[:transparent], 
					:include_notes=>params[:include_notes], :bigtext=>params[:bigtext],
					:draw_transverse=>params[:draw_transverse])
      end
      line_container.draw_lines(:canvas=>canvas, :xstart=>xbase, :ystart=>ybase + start_chrom_y, 
        :chrom_width=>@@chrom_width)
    elsif params[:alt_spacing]==:alternative
      phenoboxes = position_phenoboxes(:chrom=>chrom, :available_y=>available_y, 
				:chrom_y=>total_chrom_y, :chrom_size=>chrom_size, :chrom_start=>chrom_start)
      phenoboxes.sort!{|x,y| x.top_y <=> y.top_y}
      phenoboxes.each do |box|
        draw_phenos(canvas, box, circle_start_x, xbase, ybase + start_chrom_y, line_container,
          :chr_only=>false, :include_notes=>params[:include_notes], 
					:bigtext=>params[:bigtext],:draw_transverse=>params[:draw_transverse])
      end
      line_container.draw_lines(:canvas=>canvas, :xstart=>xbase, :ystart=>ybase + start_chrom_y, 
        :chrom_width=>@@chrom_width)
    elsif params[:alt_spacing]==:equal
      orig_circle=@@circle_size
      phenoboxes = get_pheno_boxes_equal_spacing(available_y, total_chrom_y, chrom,
				chrom_size, chrom_start)
      # sort by y location
      phenoboxes.sort!{|x,y| x.top_y <=> y.top_y}
      phenoboxes.each do |box|
        draw_phenos_equal(canvas, box, circle_start_x, xbase, ybase + padding.to_f/2, 
          :chr_only=>params[:chr_only], :include_notes=>params[:include_notes],
					:bigtext=>params[:bigtext],:draw_transverse=>params[:draw_transverse])
      end
      @@circle_size=orig_circle
    end
		
		if params[:zoomstart]
			interval_y = end_chrom_y - start_chrom_y
			mini_start_y = start_chrom_y + interval_y / 3.to_f
			mini_end_y = end_chrom_y - interval_y / 3.to_f
			mini_interval_y = mini_end_y - mini_start_y
			mini_startbp = 0
			mini_chromsize = chrom.size
			if centromere_pos[0]
				centromere_y = mini_interval_y * (((centromere_pos[0]+centromere_pos[1])/2)/chrom.size.to_f) + mini_start_y
				centromere_start = mini_interval_y * (centromere_pos[0]/chrom.size.to_f) + mini_start_y
				centromere_end = mini_interval_y * (centromere_pos[1]/chrom.size.to_f) + mini_start_y
			end
			params[:chr_only] ? chrom_width_mult=4 : chrom_width_mult=6
			mini_xbase = xbase-@@chrom_width*chrom_width_mult
			width_adjust=0.5
			draw_chr(:canvas=>canvas, :centromere_y=>centromere_y, :start_chrom_y=>mini_start_y, 
				:end_chrom_y=>mini_end_y, :xbase=>mini_xbase, :ybase=>ybase, :chromnum=>chrom.display_num,
				:thickness_mult=>params[:thickness_mult], :chr_only=>true, 
				:bigtext=>params[:bigtext], :cent_start=>centromere_start, :cent_end=>centromere_end,
				:shade=>params[:shade], :chrom_start=>mini_startbp, :chrom_bp=>mini_chromsize,
				:chrom=>chrom, :width_adjust=>width_adjust)
			
			# draw lines showing where the zoom occurs
			mini_z_start_y = mini_interval_y * (chrom_start/chrom.size.to_f) + mini_start_y
			mini_z_end_y = mini_interval_y * ((chrom_start+chrom_size)/chrom.size.to_f) + mini_start_y
			connect_start_y = start_chrom_y
		  connect_end_y = end_chrom_y
			min_x_start = @@chrom_width*width_adjust
			min_x_ext = @@chrom_width + min_x_start
			min_x_end = @@chrom_width*(chrom_width_mult-1)	
			line_top= [min_x_start, mini_z_start_y, min_x_ext, mini_z_start_y, min_x_end, connect_start_y]
			line_bottom=[min_x_start, mini_z_end_y, min_x_ext, mini_z_end_y, min_x_end, connect_end_y]
			stroke_width = get_stroke_width(params)
			canvas.g.translate(mini_xbase,ybase) do |draw|
				draw.polyline(line_top).styles(:stroke=>'darkgray',:stroke_width=>stroke_width, :fill=>'none')
				draw.polyline(line_bottom).styles(:stroke=>'darkgray',:stroke_width=>stroke_width, :fill=>'none')
			end
		end
  end

 
  # ybase is from start of chromosome drawing
  # need start of chromosome and start of bins
  def self.draw_phenos(canvas, phenobox, start_x, xbase, ybase, line_container, params)
    
    y = phenobox.top_y - @@drawn_circle_size * 0.75
    x = start_x
    
    unless $color_column_included
      params[:transparent] ? opacity = 0.05 : opacity = 1.0
    else
      params[:transparent] ? opacity = 0.55 : opacity = 1.0
    end

		annotation_x=annotation_y=0
		font_size = get_font_size(params) / 1.35
    phenobox.line_colors.each do |linecolor|
      canvas.g.translate(xbase,ybase) do |draw|
				if params[:draw_transverse]
					if phenobox.chrom_end_y - phenobox.chrom_y <= 1.0
						line_container.add_line(phenobox.chrom_y, :stroke=>linecolor)
					else
						(phenobox.chrom_end_y-phenobox.chrom_y).round.times {|i| line_container.add_line(phenobox.chrom_y+i, :stroke=>linecolor)}
					end
				end
				if params[:chr_only]
					if params[:include_notes] and phenobox.note
						annotation_x = start_x-@@circle_size
						annotation_y = phenobox.chrom_y+@@drawn_circle_size.to_f/2.25
					end
				else
					draw.line(@@chrom_width,phenobox.chrom_y.round,start_x,phenobox.top_y).styles(:stroke=>linecolor,:stroke_width=>1) unless params[:chr_only]
				end
      end
    end
    unless params[:chr_only]
			x = start_x
			annotation_y = y+@@drawn_circle_size.to_f/2.25 + @@drawn_circle_size * 0.59
      phenobox.phenocolors.each_with_index do |color, i|
        if i % @@drawn_circles_per_row == 0
          y += @@drawn_circle_size * 0.75
          x = start_x
        end
        canvas.g.translate(xbase, ybase) do |draw|
          phenobox.phenoshapes[i].draw(draw,@@drawn_circle_size,x,y,color,@@circle_outline)
        end
        x += @@drawn_circle_size
      end
			if params[:include_notes] and phenobox.note
				phenobox.phenocolors.length >= @@drawn_circles_per_row ? annotation_x = start_x + @@drawn_circles_per_row* @@drawn_circle_size : annotation_x = x
			end
    end
		if params[:include_notes] and phenobox.note
			canvas.g.translate(xbase, ybase).text(annotation_x,annotation_y) do |write|
				write.tspan(phenobox.note).styles(:font_size=>font_size, :text_anchor=>'start')
			end
		end
  end
  
  # ybase is from start of chromosome drawing
  def self.draw_phenos_equal(canvas, phenobox, start_x, xbase, ybase, params)
    
    y = phenobox.top_y - @@circle_size * 0.75
    x = start_x
    
    phenobox.line_colors.each do |linecolor|
      canvas.g.translate(xbase,ybase) do |draw|
        if phenobox.chrom_end_y - phenobox.chrom_y <= 1.0
          draw.line(0, phenobox.chrom_y, @@chrom_width, phenobox.chrom_y).styles(:stroke=>linecolor, :stroke_width=>1)
        else
          draw.rect(@@chrom_width, phenobox.chrom_end_y-phenobox.chrom_y,0, phenobox.chrom_y).styles(:stroke=>linecolor, 
            :stroke_width=>1, :fill=>linecolor)
        end
        draw.line(@@chrom_width,phenobox.chrom_y,start_x,phenobox.top_y).styles(:stroke=>linecolor,:stroke_width=>1) unless params[:chr_only]
      end
    end
    
		annotation_y = y+@@drawn_circle_size.to_f/2.25 + @@drawn_circle_size * 0.75
    phenobox.phenocolors.each_with_index do |color, i|
      if i % @@num_phenos_row == 0
        y += @@circle_size * 0.75
        x = start_x
      end
      canvas.g.translate(xbase, ybase) do |draw|
        phenobox.phenoshapes[i].draw(draw,@@drawn_circle_size,x,y,color,@@circle_outline)
      end
      x += @@circle_size
    end
		if params[:include_notes] and phenobox.note
			font_size = get_font_size(params)
			x = start_x + @@drawn_circles_per_row* @@drawn_circle_size if phenobox.phenocolors.length >= @@drawn_circles_per_row
			canvas.g.translate(xbase, ybase).text(x,annotation_y) do |write|
				write.tspan(phenobox.note).styles(:font_size=>font_size, :text_anchor=>'start')
			end
		end    
  end
  
  # adds phenotypes to sets matching same SNP
  def self.get_pheno_boxes(total_chrom_y, chrom, chrom_size, chrom_start=0)
    pheno_boxes = Array.new
    
    chrom.snps.each_value do |snp|
      # center of first circle that will be pointed at 
      pos_fraction = (snp.pos.to_f-chrom_start)/chrom_size
      y_offset = pos_fraction * total_chrom_y
      y_end = (snp.endpos.to_f-chrom_start)/chrom_size * total_chrom_y
      phenobox = PhenoBox.new
      if pos_fraction <= 0.5
        phenobox.up = true
      else
        phenobox.up = false
      end
			phenobox.note = snp.note 
      snp.phenos.each do |phenopt| 
        phenobox.add_phenocolor(phenopt.pheno.color)
        phenobox.add_shape(phenopt.shape)
      end
      snp.linecolors.each_key {|col| phenobox.add_line_color(col)}
      phenobox.set_default_boundaries(y_offset, y_end)
      pheno_boxes << phenobox
    end
    
    return pheno_boxes
  end


  # for this case can spread the snps out along the chromosome and the entire
  # box dedicated to the chromosomes
  def self.get_pheno_boxes_equal_spacing(available_y, total_chrom_y, chrom, 
			chrom_size, chrom_start)
    
    pheno_boxes = Array.new
    # determine amount of y dedicated to each snp
    y_per_snp = available_y/chrom.snpnames.length.to_f
    y = 0
    chrom_offset = (available_y - total_chrom_y.to_f)/2   

    # change circle size based on number of snps
    if y_per_snp < 20
      if y_per_snp > 10
        @@circle_size = y_per_snp
      else
        @@circle_size = 10
      end
    end

    # sort by position
    chrom.sort_snps!
    chrom.snpnames.each do |snpname|
      snp = chrom.snps[snpname]
      pos_fraction = (snp.pos.to_f-chrom_start)/chrom_size
      y_offset = pos_fraction * total_chrom_y + chrom_offset
      y_end = (snp.endpos.to_f-chrom_start)/chrom_size * total_chrom_y + chrom_offset
      phenobox = PhenoBox.new
      snp.phenos.each do |phenopt| 
        phenobox.add_phenocolor(phenopt.pheno.color)
        phenobox.add_shape(phenopt.shape)
      end
			phenobox.note = snp.note
      snp.linecolors.each_key {|col| phenobox.add_line_color(col)}
      phenobox.set_even_boundaries(y_offset, y, y_end)
      pheno_boxes << phenobox
      y += y_per_snp
    end
    
    return pheno_boxes
  end
  
  
	def self.get_font_size(params)
		 params[:bigtext] ? font_size = @@circle_size * 1.5 : font_size = @@circle_size
	end
	
	def self.get_stroke_width(params)
	  line_thickness = params[:thickness_mult] || 1
    stroke_width = @@circle_size / 10 * line_thickness
    stroke_width = 1 if stroke_width < 1
		return stroke_width
	end
	
  def self.draw_chr(params)
    canvas = params[:canvas]
    centromere_y = params[:centromere_y]
    centromere_start = params[:cent_start]
    centromere_end = params[:cent_end]
    start_chrom_y = params[:start_chrom_y]
    end_chrom_y = params[:end_chrom_y]
    xbase = params[:xbase]
    ybase = params[:ybase]
    number = params[:chromnum]
		chrom = params[:chrom]
		chrom_start = params[:chrom_start]
		chrom_bp = params[:chrom_bp]
		width_adjust = params[:width_adjust] || 1.0
		increase_cyto_opacity = params[:increase_cyto_opacity] || false
		total_chrom_y = end_chrom_y-start_chrom_y
		
		chrom_width = @@chrom_width * width_adjust
		centromere_offset = chrom_width/2
		stroke_width = get_stroke_width(params)
    tpath = "M0,#{start_chrom_y} C0,#{start_chrom_y-@@circle_size/2} #{chrom_width},#{start_chrom_y-@@circle_size/2} #{chrom_width},#{start_chrom_y}"
    bpath = "M0,#{end_chrom_y} C0,#{end_chrom_y+@@circle_size/2} #{chrom_width},#{end_chrom_y+@@circle_size/2} #{chrom_width},#{end_chrom_y}"
    if params[:shade] #and centromere_y
			increase_cyto_opacity ? fill_opacity = 0.95 : fill_opacity = 0.7
			chrom.cytobands.each do |band|
				canvas.g.translate(xbase,ybase) do |draw|
					band_start = (total_chrom_y * ((band.start-chrom_start)/chrom_bp.to_f) + start_chrom_y).round
					next if band_start >= end_chrom_y
					band_end = (total_chrom_y * ((band.finish-chrom_start)/chrom_bp.to_f) + start_chrom_y).round
					# ensure no overlap on banding
					band_end = end_chrom_y if band_end > end_chrom_y
					@@cytocolors[band.type] ? fill_color = @@cytocolors[band.type] : fill_color = band.type
					draw.rect(chrom_width, band_end-band_start, 0, band_start).styles(:stroke=>'none', :fill=>fill_color, :fill_opacity=>fill_opacity)
				end
			end
    end
    
    # if drawing chromosomes only fill in with white the centromere triangle 
    # to overwrite any regions that are over the centromere
    if centromere_y
      canvas.g.translate(xbase,ybase) do |draw|
        # draw triangle and fill it with white 'rgb(255,255,255)'
        draw.styles(:fill=>'rgb(255,255,255)', :stroke=>'rgb(255,255,255)')
        xpoints = [0,centromere_offset.to_f/2,0]
        ypoints = [centromere_start,centromere_y,centromere_end]
        draw.polygon(xpoints, ypoints).styles(:stroke_width=>2)
        xpoints = [chrom_width, chrom_width-centromere_offset.to_f/2,chrom_width]
        ypoints = [centromere_start, centromere_y,centromere_end]
        draw.polygon(xpoints, ypoints).styles(:stroke_width=>stroke_width)
      end
    end
    
    chrom_style = {:stroke=>'darkgray',:stroke_width=>stroke_width, :fill=>'none'}
    
		if centromere_y
			line1 = [0,start_chrom_y,0,centromere_start,centromere_offset.to_f/2,centromere_y,
				0,centromere_end,0,end_chrom_y]
			line2 = [chrom_width,start_chrom_y,chrom_width,centromere_start,chrom_width-centromere_offset.to_f/2,centromere_y,
				chrom_width,centromere_end, chrom_width,end_chrom_y]
		else
			line1 = [0,start_chrom_y, 0, end_chrom_y]
			line2 = [chrom_width, start_chrom_y, chrom_width, end_chrom_y]
		end
    
    canvas.g.translate(xbase,ybase) do |draw|
			draw.polyline(line1).styles(:stroke=>'darkgray',:stroke_width=>stroke_width, :fill=>'none')	
			draw.path(tpath).styles(chrom_style) if chrom_start == 0
      
      draw.polyline(line2).styles(:stroke=>'darkgray',:stroke_width=>stroke_width, :fill=>'none')
      draw.path(bpath).styles(chrom_style) if chrom_bp + chrom_start  >= chrom.size
    end
    
		font_size = get_font_size(params)
		
		# add basepair locations for partial chroms
		unless chrom_start == 0
			canvas.g.translate(xbase,ybase).text(-chrom_width/4,start_chrom_y) do |write|
				write.tspan(chrom_start.to_i).styles(:font_size=>font_size/1.25, :text_anchor=>'end')
			end
		end
		
		unless chrom_bp + chrom_start >= chrom.size
			canvas.g.translate(xbase,ybase).text(-chrom_width/4,end_chrom_y+@@circle_size) do |write|
				write.tspan(chrom_start.to_i+chrom_bp.to_i).styles(:font_size=>font_size/1.25, :text_anchor=>'end')
			end
		end
	
    canvas.g.translate(xbase,ybase).text(chrom_width.to_f/2,end_chrom_y+2*font_size) do |write|
      write.tspan(number.to_s).styles(:font_size=>font_size, :text_anchor=>'middle')
    end
    
  end
end

class Title < Plotter
  
  def self.draw(params)
    xbase = params[:ybase]
    ybase = params[:xbase]
    anchor = params[:anchor] || 'middle'
    
  end
  
  def self.draw_center(params)
    xtotal = params[:xtotal]
    xcenter = params[:xpos] || xtotal.to_f/2
    title = params[:title]
    ypos = params[:ypos]
    canvas = params[:canvas]
    
    font_size = @@circle_size * 1.7
    canvas.g.translate(xcenter,ypos).text(0,0) do |write|
      write.tspan(title).styles(:font_size=>font_size, :text_anchor=>'middle')
    end
    
  end
  
end


class Ethlabels < Plotter

  def self.draw(params)
  
    canvas=params[:canvas]
    ystart=params[:ystart]
    xstart=params[:xstart]
    xtotal=params[:xtotal]
    shapes_per_row=params[:shapes_per_row]
    eth_shapes=params[:eth_shapes]
    if params[:bigtext]
      font_size = 33
      vert_offset = 2
      y_offset = 2.5
    else
      font_size = 22
      vert_offset = 2
      y_offset = 2
    end  
    
    shape_space = xtotal.to_f/shapes_per_row
    y = 0
    x = 0   
    shape_size = @@circle_size 
		curr_eth=0
    eth_shapes.each_pair do |ethnicity, shape|
      canvas.g.translate(xstart,ystart) do |pen|
        shape.draw(pen,shape_size,x,y,'none','black')
      end
      canvas.g.translate(xstart,ystart).text(x+@@circle_size*1.5,y+@@circle_size.to_f/vert_offset) do |text|
          text.tspan(ethnicity).styles(:font_size=>font_size)
      end
      x+=shape_space
			curr_eth+=1
			if curr_eth % shapes_per_row==0
				y+=@@circle_size*y_offset 
				x=0
			end
    end
    
  end
  
end


class PhenotypeLabels < Plotter
  
	def self.phenotypes_per_row(maxname_length, params)
		
		# total number of characters for each type
		if(params[:big_font])
			if params[:zoom]
				label_size = 33
				char_per_row = label_size * 3
			else 
				label_size = 32
				char_per_row = label_size * 4
			end
		else
			if params[:zoom]
				label_size = 40
				char_per_row = label_size * 4
			else
				label_size = 38
				char_per_row = label_size * 5
			end
		end
		
		label_size = maxname_length if maxname_length > label_size
		phenos_per_row = char_per_row/label_size.to_f
		phenos_per_row *= params[:chroms_in_row].to_f / 12	
		return phenos_per_row.round
	end
	
	
  def self.draw(params)

    canvas=params[:canvas]
    ystart=params[:ystart]
    xstart=params[:xstart]
    phenoholder=params[:phenoholder]
    phenos_per_row=params[:pheno_row]
    xtotal=params[:xtotal]
    shape=params[:shape]
    
    pheno_space = xtotal.to_f/phenos_per_row
    
    radius = @@circle_size.to_f/2
    y = 0
    x = 0
    
    if params[:bigtext]
      font_size = 33
      vert_offset = 2
      y_offset = 2.5
    else
      font_size = 22
      vert_offset = 2
      y_offset = 2
    end  
    phenokeys = phenoholder.phenonames.keys.sort{|a,b| phenoholder.phenonames[a].sortnumber <=> phenoholder.phenonames[b].sortnumber}
    phenos_per_column = phenokeys.length / phenos_per_row 
    phenos_column_rem = phenokeys.length % phenos_per_row 
    curr_pheno = 0

			phenos_per_row.times do |col|
				phenos_to_do = phenos_per_column
				if phenos_column_rem > 0
					phenos_to_do += 1
					phenos_column_rem -= 1
				end
      
				phenos_to_do.times do |row|
					pheno = phenoholder.phenonames[phenokeys[curr_pheno]]
					curr_pheno += 1
					canvas.g.translate(xstart,ystart) do |draw|
						shape.draw(draw,@@circle_size,x,y,pheno.color,'black')
					end
					canvas.g.translate(xstart,ystart).text(x+@@circle_size*1.5,y+@@circle_size.to_f/vert_offset) do |text|
						text.tspan(pheno.name).styles(:font_size=>font_size)
					end
					y += @@circle_size * y_offset
				end
      
				x += pheno_space
				y = 0
			end
	end # end draw
	
end # PhenotypeLabels


def draw_plot(genome, phenoholder, options)
  
  if options.pheno_spacing == 'standard'
    alternative_pheno_spacing = :standard
  elsif options.pheno_spacing == 'equal'
    alternative_pheno_spacing = :equal
  else
    alternative_pheno_spacing = :alternative  
  end
  
  options.thin_lines ? circle_size = 20 : circle_size = 20

	total_num_chromosomes = genome.chromosomes.length-1
	chroms_in_row = ChromosomePlotter.calc_chr_per_row(total_num_chromosomes)
	num_chr_rows = total_num_chromosomes/chroms_in_row.to_f
	num_chr_rows = (num_chr_rows + 1).to_i if num_chr_rows.to_i != num_chr_rows
	if(options.zoomchr)
		options.chr_only ? num_circles_in_row=2 : num_circles_in_row=20
		options.zoomstart=0 if options.zoomstart and options.zoomstart < 0
		chr = genome.get_chrom_by_name(options.zoomchr)
		options.zoomend=chr.size if options.zoomend and options.zoomend > chr.size
		options.zoomstart ? max_chrom_size=options.zoomend-options.zoomstart : max_chrom_size=chr.size
		chrom_width = circle_size * 3.5
	else
		options.chr_only ? num_circles_in_row=2 : num_circles_in_row=7
		max_chrom_size = genome.max_chrom_size
		chrom_width = circle_size * 1.5
	end

	Plotter.set_circle(circle_size, :size=>options.circle_size)
	Plotter.set_maxchrom(max_chrom_size)
  chrom_circles_width = circle_size * num_circles_in_row
  chrom_box_width = chrom_circles_width + chrom_width
  ChromosomePlotter.set_chrom_width(chrom_width)
  ChromosomePlotter.set_phenos_row(num_circles_in_row-1, :size=>options.circle_size)
  ChromosomePlotter.set_circle_outline('none') unless options.circle_outline
	ChromosomePlotter.set_cyto_colors if options.shade_inaccessible
  title_margin = circle_size * 7
	
	row_starts = Array.new
  row_starts << title_margin
	row_box_max = Array.new

  max_chrom_height = 40 * circle_size
  max_chrom_box = max_chrom_height + circle_size * 4
	row_box_max << max_chrom_box
	last_max_chrom_box = max_chrom_box
  # X chromosome will be largest chromosome in second row
	if(options.zoomchr)
		last_max_chrom_box *= 1.5
	else
		for i in 1..num_chr_rows-1
			second_row_start = last_max_chrom_box + row_starts[i-1]
			second_row_start -= circle_size*2 if alternative_pheno_spacing == :standard
			row_starts << second_row_start
			total_num_chromosomes < (i+1) * chroms_in_row ? lastrange = total_num_chromosomes : lastrange = (i+1) * chroms_in_row
			last_max_chrom_box = max_chrom_box * genome.max_in_range((chroms_in_row*i)+1..lastrange)/max_chrom_size.to_f
			row_box_max << last_max_chrom_box
		end
	end

	phenotypes_per_row = PhenotypeLabels.phenotypes_per_row(phenoholder.maxname,
		:big_font=>options.big_font, :zoom=>options.zoomchr, :chroms_in_row=>chroms_in_row)
	
	options.big_font ? label_offset_y = 2.5 : label_offset_y = 2
	
  phenotype_rows = phenoholder.phenonames.length/phenotypes_per_row
  phenotype_rows += 1 unless phenoholder.phenonames.length % phenotypes_per_row == 0

  total_y = row_starts.last + last_max_chrom_box 
	total_y += last_max_chrom_box / 10 if options.chr_only
	single_chrom_total_y = total_y - row_starts[0]
  # add row showing shapes/ethnicities when needed
  eth_shapes = genome.get_eth_shapes
  if eth_shapes.length > 1 and !options.chr_only
		eth_label_row_size = circle_size * label_offset_y
		max_ethlength=0
		eth_shapes.each_pair {|ethnicity,shape| max_ethlength = ethnicity.length if ethnicity.length > max_ethlength}
		ethlabels_per_row = PhenotypeLabels.phenotypes_per_row(max_ethlength,
			:big_font=>options.big_font, :zoom=>options.zoomchr, :chroms_in_row=>chroms_in_row)
		ethlabel_rows = eth_shapes.length / ethlabels_per_row
		ethlabel_rows += 1 unless eth_shapes.length % ethlabels_per_row == 0
		
		eth_label_y_start = eth_label_row_size + total_y + circle_size
		total_y += eth_label_row_size*ethlabel_rows + circle_size		
  end

  # each row should be 2 circles high + 2 circle buffer on top
  phenotype_labels_total = circle_size * label_offset_y * (phenotype_rows+1)
	phenotype_labels_total += circle_size * 3
  phenotype_labels_y_start = total_y + (circle_size * label_offset_y)/2
	phenotype_labels_y_start += circle_size * 3
  total_y += phenotype_labels_total unless options.chr_only
  # total y for now
	
	# default width is 8 for 12 chromosomes in a row
  width_in = 8 * chroms_in_row.to_f/12

	padded_width = circle_size
	x_per_chrom = chrom_width + num_circles_in_row * circle_size
  # total_y is 2 for chromsome width 6 for circles * number of chroms + space on sides
  options.zoomchr ? total_x = x_per_chrom * 4 + padded_width*2 : total_x = x_per_chrom * chroms_in_row + padded_width * 2
	total_x += x_per_chrom * 4 if options.zoomchr and options.zoomstart and options.chr_only
	
	# determine how many additional x based on the starting position for each
	# change to an array that lists the X start for each chromosome
	# as work way across can add up total of the inches and adjust overall
	# size - the chromosomes match up as 0 to 12 (which is 1 to 13, etc.)
	# want to make them align the same along the horizontal grid 

	# first chromosomes start at standard left position
	x_chr_start = Array.new(chroms_in_row+1){ |i| 0 }
	additional_notation_x=0
	for i in 2..chroms_in_row+1
		if options.include_notes
			# adjust for maxphenos of previous chromosome
			# 3 characters per circle? for small text and 2 for big (font size diff is 1.5)
			# look at num_circles_in_row and then see if maxphenos plus notes will fit
			options.big_font ? chars_per_circle=1.1 : chars_per_circle=1.6
		
			# compare all the chromosomes that line up and use the one with the greatest circles needed
			circles_needed=0
			zero_notes = true
			for rownum in 0..num_chr_rows-1
				chrom_number = i+rownum*chroms_in_row-1

				if chrom_number < genome.chromosomes.length-1
					genome.chromosomes[chrom_number].maxphenos > num_circles_in_row-1 ? maxphenos = num_circles_in_row-1 : maxphenos = genome.chromosomes[chrom_number].maxphenos
					curr_circles_needed = maxphenos * Plotter.get_circle_multiplier + genome.chromosomes[chrom_number].note_length/chars_per_circle.to_f + 1
					circles_needed = curr_circles_needed if curr_circles_needed > circles_needed
					zero_notes = false if genome.chromosomes[chrom_number].note_length >  0
				end
			end
			if zero_notes
				if circles_needed < num_circles_in_row
					circles_needed = circles_needed * Plotter.get_circle_multiplier
				else
					circles_needed += 0.5 * Plotter.get_circle_multiplier
				end
			end

			size_needed = circles_needed * circle_size
			x_chr_start[i] = chrom_width + x_chr_start[i-1] + size_needed 
			# shrinks or expands overall size
			additional_notation_x += size_needed + chrom_width - x_per_chrom  #if i < 13 or size_needed > x_per_chrom
		else
			x_chr_start[i] = x_chr_start[i-1]+x_per_chrom
		end
	end
	if additional_notation_x > 0 and options.include_notes
		width_in = width_in/total_x.to_f * additional_notation_x + width_in
		total_x += additional_notation_x
	end
	
  # height can now be determined based on a width of 10 and the ratios
  # of the total x and total y
  height_in = width_in * total_y / total_x.to_f

  xmax = total_x
  ymax = total_y

  inches_ratio = height_in/width_in.to_f
  coord_ratio = ymax/xmax.to_f
  
  rvg=RVG.new(width_in.in, height_in.in).viewbox(0,0,xmax,ymax) do |canvas|
    canvas.background_fill = 'rgb(255,255,255)'
    xstart = padded_width
 
		title_x = total_x/2 - x_per_chrom/4 if options.zoomchr
    Title.draw_center(:canvas=>canvas, :title=>options.title, :ypos=>title_margin-circle_size*3,
      :xtotal=>xmax, :xpos=>title_x)
		unless(options.zoomchr)
			
			# draw each row of chroms
			for i in 0..num_chr_rows-1
				xstart = padded_width
				total_num_chromosomes < (i+1) * chroms_in_row ? lastrange = total_num_chromosomes : lastrange = (i+1) * chroms_in_row
				for chr in i*chroms_in_row+1..lastrange
					xstart = x_chr_start[chr-i*chroms_in_row] + padded_width
					ChromosomePlotter.plot_chrom(:canvas=>canvas, :chrom=>genome.chromosomes[chr], 
						:xstart=>xstart, :ystart=>row_starts[i], :height=>row_box_max[i], 
						:alt_spacing=>alternative_pheno_spacing, :chr_only=>options.chr_only,
						:transparent=>options.transparent_lines, :thickness_mult=>options.thickness_mult,
						:bigtext=>options.big_font, :shade=>options.shade_inaccessible,
						:include_notes=>options.include_notes, :draw_transverse=>options.transverse_lines)					
				end
			end
		else
			# center single chromosome
			xstart = total_x/2 - x_per_chrom/2
			height = single_chrom_total_y
			ChromosomePlotter.plot_chrom(:canvas=>canvas, :chrom=>genome.get_chrom(options.zoomchr), 
					:xstart=>xstart, :ystart=>row_starts.first, :height=>single_chrom_total_y, 
					:alt_spacing=>alternative_pheno_spacing, :chr_only=>options.chr_only,
					:transparent=>options.transparent_lines, :thickness_mult=>options.thickness_mult,
					:bigtext=>options.big_font, :shade=>options.shade_inaccessible,
					:include_notes=>options.include_notes, :zoomstart=>options.zoomstart,
					:zoomend=>options.zoomend, :zoomchr=>options.zoomchr, :draw_transverse=>options.transverse_lines)
		end
  
    # insert a row listing the shapes for the ethnicity shapes when more than one
    eth_shapes = genome.get_eth_shapes
    Ethlabels.draw(:canvas=>canvas, :xstart=>padded_width, :bigtext=>options.big_font,
      :eth_shapes=>eth_shapes, :ystart=>eth_label_y_start, :shapes_per_row=>ethlabels_per_row,
      :xtotal=>xmax-padded_width) if eth_shapes.length > 1 and !options.chr_only
    
    eth_shapes.length > 1 ? label_shape=PhenoSquare.new : label_shape = PhenoCircle.new
    PhenotypeLabels.draw(:canvas=>canvas, :xstart=>padded_width, :ystart=>phenotype_labels_y_start,
      :phenoholder=>phenoholder, :pheno_row=>phenotypes_per_row, :xtotal=>xmax-padded_width,
      :bigtext=>options.big_font, :shape=>label_shape) unless options.chr_only
  
  end

  # produce output file
  outfile = options.out_name + '.' + options.imageformat
  print "\n\tDrawing #{outfile}..."
  STDOUT.flush
	begin
		img = rvg.draw
		img.write(outfile)
	rescue
		exit!
	end

  print " Created #{outfile}\n\n" 
end

options = Arg.parse(ARGV)

options.highres ? RVG::dpi=1200 : RVG::dpi=300
srand(options.rand_seed)

genome = Genome.new
chrom_reader = ChromosomeFileReader.new
options.genome_file ? genome.set_chroms(chrom_reader.parse_file(options.genome_file)) : genome.set_chroms(Chromosome.create_human_chroms)
phenoholder = PhenotypeHolder.new(:color=>options.color)
filereader = PhenoGramFileReader.new

#begin
  filereader.parse_file(options.input, genome, phenoholder, :chr_only=>options.chr_only,
		:zoomchr=>options.zoomchr, :zoomstart=>options.zoomstart, :zoomend=>options.zoomend)
	if options.shade_inaccessible and File.exists?(options.cytobandfile)
		cytoreader = CytoBandFileReader.new
		cytoreader.parse_file(options.cytobandfile, genome)
	end
	genome.remove_empty if options.restrict_chroms
	if options.zoomchr
		if options.zoomchr.length > 1
			genome.remove_unwanted(options.zoomchr)
			options.zoomchr = nil
		elsif options.zoomchr.length == 1
			options.zoomchr = options.zoomchr[0]
		end
	end
#rescue => e
#  puts "ERROR:"
#  puts e.message
#  exit(1)
#end

draw_plot(genome, phenoholder, options)

