import random;
import uuid;
import from agents { CaseSpec, SuspectSpec, ClueSpec, ClueInfo, game_master, suspect_reply, give_hint, reveal_story }
import from game.types { PublicSuspect, PublicClue, PublicCase, QuestionOut, HintOut, AccuseOut, Culprit }
import from game.graph { Case, Suspect, Clue, ChatLine, HasSuspect, HasClue, HasChat, Knows, Breaks, Said }
import from game.rules { DiffCfg, difficulty_cfg, apply_score, final_score, rank, validate_case }
import from game.fallback { load_fallback_case }

glob THEMES: list[str] = [
    "a Sri Lankan wedding", "a Colombo office", "a temple festival", "a tea estate bungalow",
    "a train journey to Ella", "a cricket club dinner", "a village poya day fair", "a Galle fort hotel"
];

# ---------------- helpers (underscore = not exposed as endpoints) ----------------

def _find_case(case_id: str) -> Case | None {
    for c in [root -->][?:Case] {
        if c.case_id == case_id {
            return c;
        }
    }
    return None;
}

def _suspects(c: Case) -> list[Suspect] {
    return [c ->:HasSuspect:->];
}

def _clues(c: Case) -> list[Clue] {
    return [c ->:HasClue:->];
}

def _find_suspect(c: Case, sid: str) -> Suspect | None {
    for s in _suspects(c) {
        if s.sid == sid {
            return s;
        }
    }
    return None;
}

def _find_clue(c: Case, cid: str) -> Clue | None {
    for k in _clues(c) {
        if k.cid == cid {
            return k;
        }
    }
    return None;
}

def _chances_left(c: Case, cfg: DiffCfg) -> int {
    return max(0, cfg.wrong_allowed + 1 - c.wrong_guesses);
}

def _hints_left(c: Case, cfg: DiffCfg) -> int {
    if cfg.max_hints < 0 {
        return -1;
    }
    return max(0, cfg.max_hints - c.hints_used);
}

def _public_clue(k: Clue) -> PublicClue {
    return PublicClue(id=k.cid, title=k.title, text=k.text);
}

def _clue_info(k: Clue) -> ClueInfo {
    return ClueInfo(id=k.cid, title=k.title, text=k.text);
}

def _public_case(c: Case) -> PublicCase {
    cfg = difficulty_cfg(c.difficulty);
    people = [PublicSuspect(id=s.sid, name=s.name, role=s.role, style=s.style, cracked=s.cracked) for s in _suspects(c)];
    return PublicCase(
        case_id=c.case_id, title=c.title, place=c.place, what=c.what, goal=c.goal,
        difficulty=c.difficulty, suspects=people, score=c.score, hint_cost=cfg.hint_cost,
        hints_left=_hints_left(c, cfg), chances_left=_chances_left(c, cfg),
        multiplier=cfg.multiplier, used_backup=c.used_backup
    );
}

def _spec_from_graph(c: Case) -> CaseSpec {
    people: list[SuspectSpec] = [];
    for s in _suspects(c) {
        knows = [k.cid for k in [s ->:Knows:->]];
        lie: str | None = s.lie if s.lie != "" else None;
        people.append(SuspectSpec(
            id=s.sid, name=s.name, role=s.role, style=s.style,
            public_alibi=s.public_alibi, secret=s.secret, lie=lie, knows=knows
        ));
    }
    notes: list[ClueSpec] = [];
    for k in _clues(c) {
        targets = [t.sid for t in [k ->:Breaks:->]];
        target: str | None = targets[0] if len(targets) > 0 else None;
        notes.append(ClueSpec(id=k.cid, title=k.title, text=k.text, breaks=target));
    }
    return CaseSpec(
        title=c.title, where=c.place, what=c.what, culprit_id=c.culprit_id,
        true_story=c.true_story, suspects=people, clues=notes
    );
}

def _build_case(spec: CaseSpec, level: str, used_backup: bool) -> Case {
    case_id = "c_" + uuid.uuid4().hex[:8];
    c = Case(
        case_id=case_id, title=spec.title, place=spec.where, what=spec.what, difficulty=level,
        culprit_id=spec.culprit_id, true_story=spec.true_story, used_backup=used_backup, score=1000
    );
    root ++> c;
    by_id: dict[str, Suspect] = {};
    for s in spec.suspects {
        node_s = Suspect(
            sid=s.id, name=s.name, role=s.role, style=s.style, public_alibi=s.public_alibi,
            secret=s.secret, lie=s.lie if s.lie is not None else ""
        );
        c +>:HasSuspect():+> node_s;
        by_id[s.id] = node_s;
    }
    for k in spec.clues {
        node_k = Clue(cid=k.id, title=k.title, text=k.text);
        c +>:HasClue():+> node_k;
        if k.breaks is not None and k.breaks in by_id {
            node_k +>:Breaks():+> by_id[k.breaks];
        }
        for s in spec.suspects {
            if k.id in s.knows {
                by_id[s.id] +>:Knows():+> node_k;
            }
        }
    }
    return c;
}

def _breaks_lie(k: Clue, s: Suspect) -> bool {
    if not k.found or s.cracked {
        return False;
    }
    return s in [k ->:Breaks:->];
}

def _say(c: Case, s: Suspect, speaker: str, text: str) {
    c.seq += 1;
    line = ChatLine(suspect_id=s.sid, speaker=speaker, text=text, n=c.seq);
    c +>:HasChat():+> line;
    line +>:Said():+> s;
}

def _history(c: Case, s: Suspect) -> list[str] {
    by_n: dict[int, ChatLine] = {};
    for l in [c ->:HasChat:->] {
        if l.suspect_id == s.sid {
            by_n[l.n] = l;
        }
    }
    ordered = [by_n[k] for k in sorted(by_n.keys())];
    return [f"{l.speaker}: {l.text}" for l in ordered[-8:]];
}

# ---------------- public endpoints ----------------

def:pub new_case(difficulty: str = "normal") -> PublicCase {
    level = difficulty.lower();
    if level not in ["easy", "normal", "hard"] {
        level = "normal";
    }
    cfg = difficulty_cfg(level);
    spec: CaseSpec | None = None;
    for _attempt in range(2) {
        try {
            candidate = game_master(random.choice(THEMES), cfg.suspects, cfg.herrings);
            if len(validate_case(candidate, cfg)) == 0 {
                spec = candidate;
                break;
            }
        } except Exception {
            continue;
        }
    }
    used_backup = False;
    if spec is None {
        spec = load_fallback_case(cfg.suspects);
        used_backup = True;
    }
    c = _build_case(spec, level, used_backup);
    return _public_case(c);
}

def:pub question(case_id: str, suspect_id: str, text: str, clue_id: str | None = None) -> QuestionOut {
    c = _find_case(case_id);
    if c is None {
        return QuestionOut(error="unknown_case");
    }
    if c.game_over {
        return QuestionOut(error="game_over", score=c.score);
    }
    s = _find_suspect(c, suspect_id);
    if s is None {
        return QuestionOut(error="unknown_suspect", score=c.score);
    }
    shown: Clue | None = None;
    if clue_id is not None and clue_id != "" {
        shown = _find_clue(c, clue_id);
        if shown is None or not shown.found {
            return QuestionOut(error="clue_not_found_yet", score=c.score);
        }
    }
    cracks_now = shown is not None and _breaks_lie(shown, s);
    already = shown is not None and s.cracked and s in [shown ->:Breaks:->];
    known = [k for k in [s ->:Knows:->]];
    persona = SuspectSpec(
        id=s.sid, name=s.name, role=s.role, style=s.style, public_alibi=s.public_alibi,
        secret=s.secret, lie=s.lie if s.lie != "" else None, knows=[k.cid for k in known]
    );
    shown_info: ClueInfo | None = _clue_info(shown) if shown is not None else None;
    try {
        out = suspect_reply(
            persona, [_clue_info(k) for k in known], _history(c, s), text, shown_info,
            cracks_now or s.cracked, c.difficulty
        );
    } except Exception {
        return QuestionOut(error="ai_failed", score=c.score);
    }
    # The agent only proposes clue ids; the graph decides which are really found.
    fresh: list[PublicClue] = [];
    for k in known {
        if k.cid in out.proposed_clue_ids and not k.found {
            k.found = True;
            fresh.append(_public_clue(k));
        }
    }
    c.score = apply_score(c.score, "question", 0);
    if cracks_now and shown is not None {
        s.cracked = True;
        shown.used = True;
        c.score = apply_score(c.score, "crack", 0);
    }
    label = text;
    if label == "" and shown is not None {
        label = f"(shows: {shown.title})";
    }
    _say(c, s, "Player", label);
    _say(c, s, s.name, out.reply);
    return QuestionOut(
        reply=out.reply, new_clues=fresh, cracked=cracks_now, already_cracked=already, score=c.score
    );
}

def:pub hint(case_id: str) -> HintOut {
    c = _find_case(case_id);
    if c is None {
        return HintOut(error="unknown_case");
    }
    if c.game_over {
        return HintOut(error="game_over", score=c.score);
    }
    gc: Case = c;
    cfg = difficulty_cfg(gc.difficulty);
    if _hints_left(c, cfg) == 0 {
        return HintOut(error="hint_limit", score=c.score, hints_left=0);
    }
    found = [_clue_info(k) for k in _clues(gc) if k.found];
    unfound = [k.title for k in _clues(gc) if not k.found];
    cracked = [s.name for s in _suspects(gc) if s.cracked];
    try {
        text = give_hint(found, unfound, cracked);
    } except Exception {
        return HintOut(error="ai_failed", score=c.score, hints_left=_hints_left(c, cfg));
    }
    c.hints_used += 1;
    c.score = apply_score(c.score, "hint", cfg.hint_cost);
    return HintOut(hint=text, hints_left=_hints_left(c, cfg), score=c.score);
}

def:pub accuse(case_id: str, suspect_id: str, reason: str = "") -> AccuseOut {
    _unused = reason;
    c = _find_case(case_id);
    if c is None {
        return AccuseOut(error="unknown_case");
    }
    if c.game_over {
        return AccuseOut(error="game_over", score=c.score, game_over=True);
    }
    picked = _find_suspect(c, suspect_id);
    if picked is None {
        return AccuseOut(error="unknown_suspect", score=c.score);
    }
    gc: Case = c;
    cfg = difficulty_cfg(gc.difficulty);
    correct = picked.sid == c.culprit_id;
    if not correct {
        c.wrong_guesses += 1;
        c.score = apply_score(c.score, "wrong_accuse", 0);
        if c.wrong_guesses <= cfg.wrong_allowed {
            return AccuseOut(
                correct=False, game_over=False, chances_left=_chances_left(c, cfg),
                score=c.score, difficulty=c.difficulty, multiplier=cfg.multiplier
            );
        }
    }
    # Game over: right guess, or out of chances.
    c.game_over = True;
    c.score = final_score(c.score, cfg.multiplier);
    spec = _spec_from_graph(c);
    found_ids = [k.cid for k in _clues(gc) if k.found];
    story = c.true_story;
    culprit_id = gc.culprit_id;
    proof = [k.id for k in spec.clues if k.breaks == culprit_id];
    try {
        rv = reveal_story(spec, found_ids);
        story = rv.story;
        valid = [p for p in rv.proof_clues if _find_clue(gc, p) is not None];
        if len(valid) > 0 {
            proof = valid;
        }
    } except Exception {}
    culprit = _find_suspect(c, c.culprit_id);
    who = Culprit(id=c.culprit_id, name=culprit.name if culprit is not None else "");
    return AccuseOut(
        correct=correct, game_over=True, chances_left=0, score=c.score, rank=rank(c.score),
        difficulty=c.difficulty, multiplier=cfg.multiplier, culprit=who, story=story, proof_clues=proof
    );
}

def:pub get_notebook(case_id: str) -> list[PublicClue] {
    c = _find_case(case_id);
    if c is None {
        return [];
    }
    return [_public_clue(k) for k in _clues(c) if k.found];
}
