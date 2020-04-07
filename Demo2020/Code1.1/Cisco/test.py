import sys

try:
    COMPETITOR = str(sys.argv[1])
except:
    while True:
        COMPETITOR = input('Competitor FirstnameLastname: ')
        try: 
            str(COMPETITOR)
            break
        except:
            continue

print(COMPETITOR)
