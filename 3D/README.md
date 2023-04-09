# parser_tmalign.py
This Python script parses the output of a protein structure alignment tool called `TM-align` and extracts the aligned residues and their distance scores.
The output is printed to the console in a tab-separated format.

## Usage
* Save the output of a `TM-align` run to a text file (e.g., `output_tmalign.txt`).

* Run the script with the following command:
```python
python parse_tmalign_output.py output_tmalign.txt
```

## Example
If the input file contains the following lines:

```bash
Aligned length=      69, RMSD=    1.90, Seq_ID=n_identical/n_aligned=  42/  69 (60.9%), TM-score=0.46406
(1) DALMTVQELIKNLLKEQGLQSAEDLVPGDFLAVQLLVNTGEARRNIMYLKP (69)
    :.   .:  .   : : .:. :: : : : .: :::::. ::  .   ::::
(1) KVMTVKELVQNLLKDKGMSKSPDILIPKDFLAKQILLESGEAQRKLMHLQP (69)
Number of residues in common                 =   69
Number of distance constraints satisfied      =   32
Number of distance constraints not satisfied  =   37
Number of total distance constraints          = 1458
Number of total distance constraints in native=  329
Number of segment pairs with d < 0.5A         =    0
Number of segment pairs with d < 1.0A         =    1
Number of segment pairs with d < 2.0A         =    7
Number of segment pairs with d < 4.0A         =   20
Number of aligned residue pairs of d < 5.0 A  =   32
```
The script will output the following:
```makefile
DALMTVQELIKNLLKEQGLQSAEDLVPGDFLAVQLLVNTGEARRNIMYLKP  KVMTVKELVQNLLKDKGMSKSPDILIPKDFLAKQILLESGEAQRKLMHLQP  
.:.::.:..:::..:::.:.:.:::::.::..:   : : :. :::.:.:..
```

The first line shows the aligned residues for the first protein sequence, the second line shows the aligned residues for the second protein sequence, and the third line shows the distance scores between the aligned residues.
