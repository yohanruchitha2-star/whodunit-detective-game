# Live smoke test for the 4 agents. Needs GROQ_API_KEY in the environment.
# Run: jac run test_agents.jac
import from agents { CaseSpec, ClueInfo }
import from agents { game_master, suspect_reply, give_hint, reveal_story }

def check_case(spec: CaseSpec) -> list[str] {
    problems: list[str] = [];
    ids = [s.id for s in spec.suspects];
    clue_ids = [c.id for c in spec.clues];
    if len(spec.suspects) != 4 or len(set(ids)) != 4 {
        problems.append("need exactly 4 unique suspects");
    }
    if spec.culprit_id not in ids {
        problems.append("culprit_id is not a suspect");
    }
    if len(spec.clues) < 3 or len(spec.clues) > 6 {
        problems.append("need 3-6 clues");
    }
    for c in spec.clues {
        known_by = [s.id for s in spec.suspects if c.id in s.knows];
        if len(known_by) == 0 {
            problems.append(f"clue {c.id} is known by nobody");
        }
        if c.breaks is not None and c.breaks in known_by {
            problems.append(f"clue {c.id} is known by the liar it breaks");
        }
    }
    for s in spec.suspects {
        for k in s.knows {
            if k not in clue_ids {
                problems.append(f"{s.id} knows missing clue {k}");
            }
        }
    }
    culprit_lies = [s for s in spec.suspects if s.id == spec.culprit_id and s.lie is not None];
    if len(culprit_lies) == 0 {
        problems.append("culprit has no lie");
    }
    return problems;
}

with entry {
    spec = game_master("Sri Lankan wedding", 4, 1);
    print(f"CASE: {spec.title} @ {spec.where}");
    print(f"WHAT: {spec.what}");
    problems = check_case(spec);
    print(f"VALIDATION: {'OK' if len(problems) == 0 else problems}");

    liar = [s for s in spec.suspects if s.lie is not None][0];
    known = [ClueInfo(id=c.id, title=c.title, text=c.text) for c in spec.clues if c.id in liar.knows];
    out = suspect_reply(liar, known, [], "Where were you at the time?", None, False, "normal");
    print(f"{liar.name} ({liar.style}): {out.reply}  clues={out.proposed_clue_ids}");

    breaker = [c for c in spec.clues if c.breaks == liar.id];
    if len(breaker) > 0 {
        shown = ClueInfo(id=breaker[0].id, title=breaker[0].title, text=breaker[0].text);
        crack = suspect_reply(liar, known, [], "", shown, True, "normal");
        print(f"CRACKED {liar.name}: {crack.reply}");
    }

    first = spec.clues[0];
    found = [ClueInfo(id=first.id, title=first.title, text=first.text)];
    unfound = [c.title for c in spec.clues if c.id != first.id];
    hint = give_hint(found, unfound, []);
    print(f"HINT: {hint}");
    culprit_name = [s.name for s in spec.suspects if s.id == spec.culprit_id][0];
    print(f"HINT LEAKS CULPRIT: {culprit_name.lower() in hint.lower()}");

    story = reveal_story(spec, [first.id]);
    print(f"REVEAL: {story.story}  proof={story.proof_clues}");
}
