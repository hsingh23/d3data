
import json
import parse_table.parse_table as pt

table = pt.Table.from_file("data.gov.femadeclarations.csv", col_delim=",")

# example_row = zip(table.labels, table.rows[0])

states = table.get_classified_columns(lambda row: row['ST_CD'])
disasters = table.get_classified_columns(lambda row: row['INCIDENT_TYPE_CD'])

data = {}

data['state_labels'] = states.keys()
data['disaster_labels'] = disasters.keys()

data['states'] = {}

for state in data['state_labels']:
    data['states'][state] = {}
    state_dis = states[state].get_classified_columns(lambda row: row['INCIDENT_TYPE_CD'])
    for disaster in data['disaster_labels']:
        data['states'][state][disaster] = 0
        if disaster in state_dis:
            data['states'][state][disaster] = len(state_dis[disaster])


data['disasters'] = {}

for disaster in data['disaster_labels']:
    data['disasters'][disaster] = {}
    dis_state = disasters[disaster].get_classified_columns(lambda row: row['ST_CD'])
    for state in data['state_labels']:
        data['disasters'][disaster][state] = 0
        if state in dis_state:
            data['disasters'][disaster][state] = len(dis_state[state])

with open('disaster.json', 'w') as f:
    f.write(json.dumps(data))
