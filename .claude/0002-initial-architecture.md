This app in it's MVP will be deployed only to android at first.

Build a flutter app based from the src repo that has an initial 


# Data Strucutres
WordBase:
    - Word
        - An input field
        - A single valid word in the english language
    - Definition 
        - Not user input, only clarified if a word with multiple meanings
        - A dictionary definition from a database
    - Crossword clues (perhaps more than one?)
        - A set of possible crossword clues associated with the word
        - Not user input, only clarified if a word with multiple meanings
    - Associations (to be implemented)
        - User input text field
        -


# Page Flow
Landing page:
    - A standard login page, with fields for email and password, and a button for login
    - A signup field, as yet unimplemented
    - The login button takes you to the next flow


Capture Vocab Page:
- Allows you to implement a new word into the WordBase

Spaced Repition Page
- Takes the users WordBase
- As yet unimplemented

Crossword Page
- Takes the users WordBase and implements a crossword
