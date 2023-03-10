import re

seq1 = ""
seq2 = ""
distance = ""
index_distance = []
alignment = False
with open("output_tmalign.txt", "r") as f:
    for line in f.readlines():
        line = line.rstrip()

        pattern = re.search('Aligned length=\s+(\d+), RMSD=\s+(\d+\.\d+)', line)
        if pattern:
            print('Aligned length= ', pattern.group(1), end='\t')
            print('RMSD=', pattern.group(2), end='\t')

        tmscore = re.search('TM-score=\s+(\d+\.\d+)', line)
        if tmscore:
            print('TM-score=', tmscore.group(1), end='\t')


        if ' aligned residue pairs of d < 5.0 A' in line:
            alignment = True
            print('\n')
            continue
        if alignment:
            if any(i.isalpha() for i in line):
                if not seq1:
                    seq1 = line
                else:
                    seq2 = line
            if ':' in line:
                distance = line
                for i in range(len(distance)):
                    if distance[i] == ':':
                        index_distance.append(i)

print(" ".join([seq1[i] for i in index_distance]))
print(" ".join([seq2[i] for i in index_distance]))
