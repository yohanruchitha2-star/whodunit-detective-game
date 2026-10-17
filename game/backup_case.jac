import from game.shapes { CaseSpec, SuspectSpec, ClueSpec }
import from game.rules { validate_case }

def load_backup_case() -> CaseSpec {
    data = CaseSpec(
        title="The Stolen Necklace",
        where="A wedding hall in Kandy",
        what="At 9pm the bride's gold necklace vanished from the bridal room. The door was locked from the inside.",
        culprit_id="s3",
        true_story="Ruwan slipped in through the window and took the necklace. Kamal had only borrowed the key.",
        suspects=[
            SuspectSpec(
                id="s1",
                name="Kamal",
                role="driver",
                style="nervous",
                public_alibi="At the garage all evening",
                secret="He left at 8:30 and borrowed the key but did not steal it.",
                lie="At the garage all evening",
                knows=[]
            ),
            SuspectSpec(
                id="s2",
                name="Nimali",
                role="cousin",
                style="calm",
                public_alibi="",
                secret="",
                lie=None,
                knows=["k1", "k3"]
            ),
            SuspectSpec(
                id="s3",
                name="Ruwan",
                role="caterer",
                style="rude",
                public_alibi="",
                secret="He took the necklace through the window.",
                lie="He never left the kitchen",
                knows=[]
            ),
            SuspectSpec(
                id="s4",
                name="Dilani",
                role="photographer",
                style="chatty",
                public_alibi="",
                secret="",
                lie=None,
                knows=["k2"]
            )
        ],
        clues=[
            ClueSpec(
                id="k1",
                title="Garage log",
                text="Kamal left the garage at 8:30pm",
                breaks="s1"
            ),
            ClueSpec(
                id="k2",
                title="Muddy footprints",
                text="Muddy footprints near the bridal room window",
                breaks=None
            ),
            ClueSpec(
                id="k3",
                title="Nimali's sighting",
                text="Nimali saw Ruwan near the bridal room at 9",
                breaks="s3"
            )
        ]
    );
    if not validate_case(data) {
        raise ValueError("Backup case failed validation");
    }
    return data;
}
