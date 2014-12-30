# voom_mode_scenario.py
# -*- coding: utf-8 -*-

import re

headline_match = re.compile(ur'^○.*|^▽|^【[^】]*】',re.UNICODE).match
#headline_match = re.compile(ur'^○.*|^▽.*',re.UNICODE).match
#headline_match = re.compile(ur'^○.*|^▽.*').match


def hook_makeOutline(VO, blines):
    Z = len(blines)
    tlines, bnodes, levels = [], [], []
    tlines_add, bnodes_add, levels_add = tlines.append, bnodes.append, levels.append
    for i in xrange(Z):
        #if not headline_match(blines[i].decode('cp932')):
        if not headline_match(blines[i].decode('utf-8')):
            continue
        tline = ' %s|%s' %('', blines[i])
        tlines_add(tline)
        bnodes_add(i+1)
        levels_add(1)
    return (tlines, bnodes, levels)

def hook_newHeadline(VO, level, blnum, tlnum):
    tree_head = ''
    bodyLines = ['%s%s' %(u'○', tree_head), u'  　']
    return (tree_head, bodyLines)


def hook_changeLevBodyHead(VO, h, levDelta):
    exit()

