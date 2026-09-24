#!/usr/bin/env python3

import math
import re
import sys

if len(sys.argv) < 2:
	sys.exit(10)

indents = []
lines = []

with open(sys.argv[1], 'r') as f:
	for line in f:
		lines.append(line)
		if line.strip():
			expanded = line.expandtabs()
			indents.append(len(expanded) - len(expanded.lstrip()))
		else:
			indents.append(0)


spaces_per_tab = math.gcd(*indents)
indents = (int(x/spaces_per_tab) for x in indents)

def chindent(line:str, size:int):
	return size * '\t' + line.lstrip(' \t')

result = "".join(map(chindent, lines, indents)).rstrip('\n')

print(re.sub(r'^(\t+)', lambda m: '\033[44m\033[K\t|\033[0m\033[K' * len(m.group(1)), result, flags=re.MULTILINE))
reply = input('OK? [y/N]')
if reply.startswith(('y', 'Y')):
	with open(sys.argv[1], 'w') as f:
		f.write(result)