import from uuid { uuid4 }
import from game.graph { Case, Suspect, Clue, ChatLine, Knows, Breaks, Said }
import from game.rules { apply_score, rank, filter_found_clues, breaks_lie }
import from game.backup_case { load_backup_case }
import from game.types { PublicCase, PublicSuspect, PublicClue, ChatTurn, Result }

def _find_case(case_id: str) -> Case | None {
    for c in [root -->][?:Case] {
        if c.case_id == case_id {
            return c;
        }
    }
    return None;
}

def _find_suspect(case_node: Case, suspect_id: str) -> Suspect | None {
    for s in [case_node -->][?:Suspect] {
        if s.id == suspect_id {
            return s;
        }
    }
    return None;
}

def _find_clue(case_node: Case, clue_id: str) -> Clue | None {
    for c in [case_node -->][?:Clue] {
        if c.id == clue_id {
            return c;
        }
    }
    return None;
}

def _ui_suspects(case_node: Case) -> list[PublicSuspect] {
    people: list[PublicSuspect] = [];
    for suspect in [case_node -->][?:Suspect] {
        people = people + [PublicSuspect(
            id=suspect.id,
            name=suspect.name,
            role=suspect.role,
            personality=suspect.style,
            cracked=suspect.cracked
        )];
    }
    return people;
}

def _found_clues(case_node: Case) -> list[PublicClue] {
    found: list[PublicClue] = [];
    for clue in [case_node -->][?:Clue] {
        if clue.found {
            found = found + [PublicClue(id=clue.id, text=clue.text)];
        }
    }
    return found;
}

def new_case() -> PublicCase {
    spec = load_backup_case();
    new_id = str(uuid4());
    case_node = Case(
        case_id=new_id,
        title=spec.title,
        where=spec.where,
        what=spec.what,
        goal="Find who took it.",
        score=1000,
        wrong_guesses=0,
        game_over=False,
        culprit_id=spec.culprit_id,
        true_story=spec.true_story
    );
    root ++> case_node;

    for suspect_spec in spec.suspects {
        suspect = Suspect(
            id=suspect_spec.id,
            name=suspect_spec.name,
            role=suspect_spec.role,
            style=suspect_spec.style,
            public_alibi=suspect_spec.public_alibi,
            secret=suspect_spec.secret,
            lie=suspect_spec.lie or "",
            cracked=False
        );
        case_node ++> suspect;
    }
    for clue_spec in spec.clues {
        clue = Clue(
            id=clue_spec.id,
            title=clue_spec.title,
            text=clue_spec.text,
            found=False,
            used=False
        );
        case_node ++> clue;
        for suspect_spec in spec.suspects {
            if clue_spec.id in suspect_spec.knows {
                suspect_node = _find_suspect(case_node, suspect_spec.id);
                if suspect_node is not None {
                    suspect_node +>:Knows:+> clue;
                }
            }
        }
        if clue_spec.breaks is not None and clue_spec.breaks != "" {
            target_suspect = _find_suspect(case_node, clue_spec.breaks);
            if target_suspect is not None {
                clue +>:Breaks:+> target_suspect;
            }
        }
    }
    return PublicCase(
        case_id=new_id,
        title=case_node.title,
        setting=case_node.where,
        summary=case_node.what,
        suspects=_ui_suspects(case_node),
        found_clues=[],
        score=case_node.score,
        screen="play"
    );
}

def question(case_id: str, suspect_id: str, text: str, clue_id: str | None = None) -> ChatTurn {
    case_node = _find_case(case_id);
    if case_node is None {
        return ChatTurn();
    }
    suspect = _find_suspect(case_node, suspect_id);
    if suspect is None {
        return ChatTurn();
    }
    if case_node.game_over {
        return ChatTurn();
    }

    reply = suspect.public_alibi;
    new_clues: list[dict[str, object]] = [];
    already_cracked = suspect.cracked;
    if clue_id is None {
        known_ids = [clue.id for clue in [suspect ->:Knows:->][?:Clue]];
        found_ids = [clue.id for clue in [suspect ->:Knows:->][?:Clue] if clue.found];
        proposed_ids = known_ids;
        revealed_ids = filter_found_clues(known_ids, found_ids, proposed_ids);
        for revealed_id in revealed_ids {
            clue = _find_clue(case_node, revealed_id);
            if clue is not None {
                clue.found = True;
                new_clues = new_clues + [{"id": clue.id, "title": clue.title, "text": clue.text}];
            }
        }
    } else {
        shown_clue = _find_clue(case_node, clue_id);
        if shown_clue is None or not shown_clue.found {
            return ChatTurn();
        }
        has_break_edge = len([shown_clue ->:Breaks:->][?:Suspect, id == suspect_id]) > 0;
        cracked_now = breaks_lie(has_break_edge, shown_clue.found, suspect.cracked);
        if cracked_now {
            suspect.cracked = True;
            case_node.score = apply_score(case_node.score, "crack");
            reply = "Fine. I borrowed the key.";
        } else {
            reply = "That is not about me.";
        }
    }

    chat = ChatLine(who="player", text=text);
    suspect +>:Said:+> chat;
    case_node.score = apply_score(case_node.score, "question");
    return ChatTurn(
        reply=reply,
        notebook=_found_clues(case_node),
        cracked_now=suspect.cracked and not already_cracked,
        score=case_node.score
    );
}

def hint(case_id: str) -> str {
    case_node = _find_case(case_id);
    if case_node is None or case_node.game_over {
        return "";
    }
    case_node.score = apply_score(case_node.score, "hint");
    return "Someone's alibi has a gap. Think about timing.";
}

def accuse(case_id: str, suspect_id: str, reason: str) -> Result {
    case_node = _find_case(case_id);
    if case_node is None {
        return Result();
    }
    suspect = _find_suspect(case_node, suspect_id);
    if suspect is None or case_node.game_over {
        return Result();
    }
    if suspect_id == case_node.culprit_id {
        case_node.game_over = True;
        return Result(
            correct=True,
            final=True,
            story=case_node.true_story,
            score=case_node.score,
            rank=rank(case_node.score)
        );
    }
    case_node.wrong_guesses += 1;
    case_node.score = apply_score(case_node.score, "wrong_accuse");
    if case_node.wrong_guesses >= 2 {
        case_node.game_over = True;
        return Result(
            correct=False,
            final=True,
            story=case_node.true_story,
            score=case_node.score,
            rank=rank(case_node.score)
        );
    }
    return Result(
        correct=False,
        final=False,
        story="",
        score=case_node.score,
        rank=""
    );
}
