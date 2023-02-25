import bisect
from itertools import product


def solution(info, query):
    answer = []

    lan = ['cpp', 'java', 'python', '-']
    job = ['backend', 'frontend', '-']
    car = ['junior', 'senior', '-']
    food = ['chicken', 'pizza', '-']

    combis = list(product(*[lan, job, car, food]))
    hashmap = {''.join(key): [] for key in combis}

    for line in info:
        keywords = line.split(' ')
        comb = list(
            product(*[[keyword, '-'] for keyword in keywords[:-1]]))
        for c in comb:
            hashmap[''.join(c)].append(int(keywords[-1]))

    for scores in hashmap.values():
        scores.sort()

    for q in query:
        keywords = q.split(' ')
        combi = [item for item in keywords[::2]]
        scores = hashmap[''.join(combi)]
        score = int(keywords[-1])

        if len(scores) == 0:
            answer.append(0)
            continue

        idx = bisect.bisect_left(scores, score)
        answer.append(len(scores) - idx)

    return answer
