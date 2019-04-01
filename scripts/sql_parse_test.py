import re
import os
import sys

sql_file = sys.argv[1]
write_file = sys.argv[2]

def tables_in_query(sql_str):
    # remove the /* */ comments
    q = re.sub(r"/\*[^*]*\*+(?:[^*/][^*]*\*+)*/", "", sql_str)

    # remove whole line -- and # comments
    lines = [line for line in q.splitlines() if not re.match("^\s*(--|#)", line)]

    # remove trailing -- and # comments
    q = " ".join([re.split("--|#", line)[0] for line in lines])

    # split on blanks, parens and semicolons
    tokens = re.split(r"[\s)(;]+", q)

    # scan the tokens. if we see a FROM or JOIN, we set the get_next
    # flag, and grab the next one (unless it's SELECT).
    table = set()
    get_next = False
    for tok in tokens:
        if get_next:
            if tok.lower() not in ["", "select"]:
                table.add(tok)
            get_next = False
        get_next = tok.lower() in ["from", "join"]

    return table

incr_list = []
with open(sql_file) as fp:
        for cnt, line in enumerate(fp):
                current_list=tables_in_query(line)
                incr_list.extend(list(current_list))
master_set= set(incr_list)
#rem_osa=[ x for x in master_set if not x.startswith('osa_results')]

with open(write_file,'a+') as wp:
    for item in master_set:
        print>>wp, item
