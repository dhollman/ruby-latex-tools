t = LatexTable.new(3)
t << " " << "Height" << "Weight" << endl
t << hline
t << "Person 1" << '156 cm' << '55 kg' << endl
t << "Person 2" << '183 cm' << '62 kg' << endl
t << hline
t.to_s
