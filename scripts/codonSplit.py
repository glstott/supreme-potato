from Bio import AlignIO, SeqIO 
import pandas as pd
from Bio.Seq import Seq
import sys

with open(str(sys.argv[0]), mode='r') as handle:
    with open(str(sys.argv[1]), mode='w') as f_out:
        with open(str(sys.argv[2]), 'w') as f_out2:
            for record1 in SeqIO.parse(handle, "fasta"):
                print(record1)
                seq = record1.seq
                record1.seq=Seq("".join([record1.seq[a] for a in [i for i in range(0,30020, 3)] + [i for i in range(1,30020, 3)]]) )
                SeqIO.write(record1,f_out, 'fasta') 
                record1.seq=Seq("".join([seq[a] for a in [i for i in range(2,30020, 3)]])) 
                SeqIO.write(record1,f_out2, 'fasta') 
