from epiweeks import Week, Year
import pandas as pd
from Bio import SeqIO
import sys
from datetime import date, datetime

file = str(sys.argv[1])
file2 = str(sys.argv[2])
if len(sys.argv) > 3:
	minThreshold = sys.argv[3]
else:
	minThreshold = 1
prefix = file[:-13]
df = pd.read_csv(file, sep='\t')
mode='cumulative'

df['epiweek'] = df.date.map(lambda x: Week.fromdate(datetime.strptime(x, '%Y-%m-%d')).cdcformat())
for epiweek in df.epiweek.unique():
    print(epiweek)
    if mode == 'cumulative':
        temp_df = df.loc[df.epiweek <= epiweek, :]
    else:
        temp_df = df.loc[df.epiweek == epiweek, :]
    
    if temp_df.strain.count() < minThreshold:
        continue
    
    temp_df.loc[:, ['strain', 'date']].to_csv(prefix + "_" +str(epiweek)+".dt.tsv", index=False, sep='\t', header=False)
    temp_df.to_csv(prefix + "_" +str(epiweek)+".metadata.tsv", index=False, sep='\t' )
    with open(prefix + "_" + str(epiweek)+".fasta", 'a') as out_handle:
        for record in SeqIO.parse(file2, 'fasta'):
            if record.id in temp_df.strain.unique():
                SeqIO.write(record, out_handle, "fasta")
    print(temp_df.count()[0])
