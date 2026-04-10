I found an english dictionary repo here: https://github.com/benjihillard/English-Dictionary-Database/blob/main/english%20Dictionary.csv

Need to process it into a more useful dataset for my purposes

# Prompt 1
in this file, create a python script to parse the english_dictionary.csv file. 

I want you to:
1. Create an extra column called "crossword clue"
2. Remove any entries that don't make sense for a vocab building app. Examples would be "a", "the", names, places. Put the deleted lines into a csv called unused_words.csv
3. Add a related word column. If a word is related to another word, put the root word in there. an example would be "Varnished,of Varnish" It should have Varnish in a new column.

Keep the original file, and put the new file called parsed1_english_dictionary.csv

# Prompt 2
Convert parsed1_english_dictionary.csv to a new file called parsed2_english_dictionary.json

In this conversion, convert the format to json, and collapse each identical word to multiple definitions.

For example in lines 3152 to 3154 for the word "Aim":

Aim,"To point or direct a missile weapon, or a weapon which propels as missile, towards an object or spot with the intent of hitting it; as, to aim at a fox, or at a target.",,
Aim,"To direct the indention or purpose; to attempt the accomplishment of a purpose; to try to gain; to endeavor; -- followed by at, or by an infinitive; as, to aim at distinction; to aim to do well.",,
Aim,To guess or conjecture.,,

Becomes: 

"

{
    "word": "Aim",
    "definitions" : [
        "To point or direct a missile weapon, or a weapon which propels as missile, towards an object or spot with the intent of hitting it; as, to aim at a fox, or at a target.",
        To direct the indention or purpose; to attempt the accomplishment of a purpose; to try to gain; to endeavor; -- followed by at, or by an infinitive; as, to aim at distinction; to aim to do well.",
        "To guess or conjecture."
    ],
    "crossword_clues" : [

    ],
    "related_word : [

    ]
}

# Prompt 3
For each word in parsed2_english_dictionary.json, generate a single entry into the crossword_clues field.

Output this into a file called possible_word_base_dynamic_db.json