#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import re
import sys


def read_sentence(stream, strip=None):
    sent_id = None
    comments = []
    tokens = []
    for line in stream:
        if line.endswith("\n"):
            line = line[:-1]
        if line.startswith("#"):
            match = re.match(r"^# sent_id ?= ?(.+)$", line)
            if match:
                sent_id = match.group(1)
                if strip and sent_id.startswith(strip):
                    sent_id = sent_id[len(strip):]
                comments.append("# sent_id = {}".format(sent_id))
            else:
                comments.append(line)
        elif line:
            tokens.append(line)
        else:
            break
    return sent_id, comments, tokens


class Fold:
    def __init__(self, i, conllulex=False):
        suffix = "conllu"
        if conllulex:
            suffix += "lex"
        self.train = open("train-%02d.%s" % (i, suffix), "w")
        self.parse = open("parse-%02d.%s" % (i, "conllu" if conllulex else "ct"), "w")
        self.test = open("test-%02d.%s" % (i, suffix), "w")
        self.count = 0

    def close(self):
        self.train.close()
        self.parse.close()
        self.test.close()


def main(arguments):
    #
    # identifiers that correspond to actual STREUSLE/UCCA items
    #
    items = set()
    for doc_ids in arguments.doc_ids:
        with open(doc_ids, "r") as stream:
            for doc_id in stream:
                items.add(doc_id.strip())

    #
    # keep track of per-fold output streams and counters
    #
    folds = [Fold(i, arguments.conllulex) for i in range(arguments.n)]
    m = n = 0
    while True:
        sent_id, comments, tokens = read_sentence(arguments.input, strip=arguments.strip)
        if not tokens:
            break
        n += 1
        parse = None
        if re.sub(r"-[^-]+$", "", sent_id) in items:
            parse = m % arguments.n
            fold = folds[parse]
            m += 1
            masked_tokens = ["\t".join(field if i < 2 or field == "SpaceAfter=No" else "_"
                                       for i, field in enumerate(token.split("\t")))
                             for token in tokens]
            print("\n".join(comments + masked_tokens + [""]), file=fold.parse)
            print("\n".join(comments + tokens + [""]), file=fold.test)
            fold.count += 1
        for i, fold in enumerate(folds):
            if i != parse:
                print("\n".join(comments + tokens + [""]), file=fold.train)
                fold.count += 1

    for i, fold in enumerate(folds):
        fold.close()
        if fold.count != n:
            print("fold %02d contains %d sentences, but there should be %d."
                  % (i, fold.count, n), file=sys.stderr)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="CoNLL-U[-LEX] Jack-Knifing")
    parser.add_argument("--n", type=int, default=5)
    parser.add_argument("--doc-ids", nargs="+")
    parser.add_argument("--strip", default="reviews-")
    parser.add_argument("--conllulex", action="store_true")
    parser.add_argument("input", nargs="?",
                        type=argparse.FileType("r"), default=sys.stdin)
    main(parser.parse_args())
