srs
===

A Spaced Repetition System is a study tool which works by spacing out exercises
so as to learn in the most efficient manner possible.  Further information can
be found at the following Wikipedia pages:

 * [Spacing Effect][1]
 * [Forgetting Curve][2]
 * [Spaced Repetition][3]

`srs` is a command-line based implementation of the spaced repetition system.  It
is designed to be highly extensible and to promote the sharing of data for study
by others.

Installation
------------

`srs` is distributed as a Gem.  Make sure you have Ruby and RubyGems installed,
and then type:

    $ gem install srs

Usage
-----

This first release of `srs` is an _alpha_ release -- it is functionally
complete, but the user interface is in its very early stages, documentation is
lacking, and there may be bugs.  Since elements in the workspace format may
change, it is not recommended to use this version for actual practice.  Treat it
as a "sneak preview".  Version 0.2 is intended to be much closer to a final,
usable system, so please watch the project for updates on when that version is
released.

With that in mind, read on...

### Initialising a workspace

The first thing you will want to do once you've installed `srs` is to initialise
a _workspace_.  This is where all the data required for one set of material you
want to study reside.  It is generally a good idea to group related items
together -- for example, I have a workspace for Japanese vocabulary, another for
kanji, and another for poetry and quotations which I'd like to remember.

How you think the things you want to learn should be distributed is a
personal choice, and you should consider for yourself what will work best for
you.  For example, some people might prefer to put the Japanese vocabulary and
the kanji together in one workspace -- that is fine.  Merging or splitting
workspaces at a later stage is relatively easy, so do experiment!

To initialise a workspace, create a directory and run the following command
inside it:

    $ srs init

### Adding an exercise

In `srs`, a single item of practice or revision is called an _exercise_.  These
can be anything -- a flashcard-style question-and-answer, or a more interactive
form of practice.  What a particular exercise entails depends entirely on what
it is you want to practice, and for that reason `srs` introduces the concept of
_models_.

A model is a Ruby class which defines how an exercise is performed.  `srs` comes
packaged with the most basic kind of model, a flashcard, which is distributed
under the name `SimpleFlashcard`.  You can create your own models, but for now
we'll make use of the `SimpleFlashcard` model to get something up and running
quickly.

A `SimpleFlashcard` exercise comes in two parts:

 * The _data_, which usually contains the actual thing you want to test
 * The _exercise specification_, which determines how to use that data.

This separation allows you to use the same data for multiple exercises.  In this
example, we're going to create a "Production" and a "Recognition" card for the
Japanese word, 勉強, which means "study".

The first thing we need to do is create the DataFile.  `SimpleFlashcard`
currently expects its data in an XML format, with a root `<fields>` node
containing an element with the text for each field.  Run the following from
inside the workspace directory you created (The ^D at the end signifies pressing
Control-D to send the end-of-file marker to `srs`):

    $ srs insert-into data 勉強
    <fields>
    	<Word>勉強</Word>
    	<Pronunciation_Hiragana>べんきょう</Pronunciation_Hiragana>
    	<Pronunciation_Romaji>Benkyou</Pronunciation_Romaji>
    	<Meaning>Study</Meaning>
    </fields>
    ^Ddata/勉強

You should see the output after pressing ^D as above, `data/勉強`.  The
`insert-into` command reads data in from STDIN and places it in either the
"data" or "exercises" section, giving it the ID passed as the second parameter.
It outputs an absolute ID which can be used by other `srs` commands to access
that data.

We now have data containing four fields related to the word.  We can combine
these fields in a variety of ways to generate a number of exercises.  Here we'll
generate two; one to produce the English meaning when shown the word and the
pronunciation; the other to produce the Japanese word when shown the English.
Input the following:

    $ srs insert-into exercises 勉強.recognition
    Data: 勉強
    Model: SimpleFlashcard

    [Word]
    [Pronunciation_Hiragana]
    ---
    [Meaning]
    ^Dexercises/勉強.recognition

Note the blank line between the set of key-value pairs and the text below.
`SimpleFlashcard` expects a series of headers, followed by a blank line,
followed by some metadata.  The metadata is in two parts: the question, which is
everything before the "---" string, and the answer, which is everything that
comes after it.  Any words within square brackets are substituted with the value
of their corresponding field in the data.

As with the previous command, this command outputs the absolute ID once it has
completed.  Let's add the second exercise:

    $ srs insert-into exercises 勉強.production
    Data: 勉強
    Model: SimpleFlashcard

    [Meaning]
    ---
    [Word]
    ^Dexercises/勉強.production

As you can see, this is just the same exercise, with the question and answer
reversed.  Also, we are ignoring pronunciation for this one.

You will notice, neither of these exercises make use of the "Pronunciation_Romaji"
field.  The truth is, I don't much like Romaji.  But it is entirely reasonable
to add fields you won't use as part of the exercises to the data; you may choose
to create exercises which make use of that data later, or you may just want to
look it up (for example, you could include the link to a URL where you
discovered the information).

### Scheduling an exercise

The next thing we must do is schedule the exercises we've just created.  If we
don't do this, they will never enter the `srs` scheduling system, and so they
will simply sit there unasked!

There have been a number of spaced repetition algorithms developed over the
years, perhaps the most famous of which are the [Pimsleur Graduated Recall][4]
and [SuperMemo 2][5] algorithms.  As with models, `srs` allows you to define
your own custom spacing algorithm by creating a _scheduler_.  The base
distribution comes with probably the most popular spacing algorithm
pre-installed, SuperMemo 2.  We'll use that one.

In the following two commands, the IDs we're passing in match those we passed in
when creating the exercises previously.  Strictly speaking, the full IDs are
`exercises/勉強.recognition` and `exercises/勉強.production` respectively, but
since the `schedule` command only ever interacts with exercises and never data,
we can drop the section name.

    $ srs schedule -s SuperMemo2 勉強.recognition
    schedule/pending/20120708003132.386
    $ srs schedule -s SuperMemo2 勉強.production
    schedule/pending/20120708003149.754

### Doing some reps -- new exercises

Now that you've scheduled some exercises, you're ready to do some reps.  Let's
ask `srs` what the next new exercise is which is available for learning:

    $ srs next-new
    20120708003132.386

The ID of the first exercise you scheduled above should be output.  In order to
actually test ourselves, we'll need the ID of the exercise we want to run.  We
can get this from the `Exercise` field stored in the schedule (as always,
remembering to substitute the example ID below with your own):

    $ srs get-field exercise 20120708003132.386
    勉強.recognition

An exercise ID will be output, which we can feed straight into `do-exercise`:

    $ srs do-exercise 勉強.recognition
    勉強
    べんきょう
    >

At this point you are given a prompt.  Let's enter the correct answer, "Study",
and see what happens:

    > Study
    Correct.
    You scored: 1.0

Scores in `srs` are normalised from 0-1, so 1.0 is a full score.  Well done!  We
still need to enter this into the scheduler so that it knows when next to repeat
the exercise.  Enter the following to reschedule the exercise.  The ID is the
_schedule_ ID, not the one for the exercise:

    $ srs reschedule 20120708003132.386 1.0
    Exercise rescheduled for 2012-07-09 00:00:00 +0900

Excellent!  We'll see this exercise again tomorrow.

It's actually possible to wrap up most of the above in a single line.  The
following assumes you use a `bash` shell, though other shells may be similar:

    $ SCHEDULE=$(srs next-new); EXERCISE=$(srs get-field exercise $SCHEDULE); srs do-exercise $EXERCISE

This time we'll try answering the question incorrectly:

    Study
    > 遊ぶ
    勉強
    Was your answer: [h] Correct, [j] Close, [k] Wrong, or [l] Very Wrong?
    > l
    You scored: 0.0

When you enter a wrong answer, the `SimpleFlashcard` doesn't attempt to judge
for itself whether or not you were close to the right answer.  Instead, it shows
you the correct answer and lets you specify how close you thought you were.  In
this case, we were miles off, so we selected 'l', to fail the exercise
completely.  Now to reschedule the exercise:

    $ srs reschedule $SCHEDULE 0.0
    Exercise rescheduled for 2012-07-09 00:00:00 +0900
    Exercise failed; marked for repetition

Since we failed the exercise, the scheduler has marked it for repetition.  This
means that once we've finished all our scheduled reps for the day, we will be
presented with this exercise (and any other failed exercises), to try again until
we have managed to pass them.  Note that only the first attempt affects the
interval; subsequent repetitions are simply practice.

### Practice makes perfect!  Repeating exercises

For the most part, you're going to be practicing exercises you've already done
once.  The flow for this is very similar to the above, except that instead of
`next-new` we use the `next-due` command.

Before we can use this command, however, we need to update the srs queue:

    $ srs queue

This command tells `srs` to look through the schedules and determine which
exercises are due for practice.  We can now use `next-due` similarly to the
way we practised new exercises in the previous section:

    $ SCHEDULE=$(srs next-due); EXERCISE=$(srs get-field exercise $SCHEDULE); srs do-exercise $EXERCISE
    Study
    > 勉強
    Correct.
    You scored: 1.0

    $ srs reschedule $SCHEDULE 1.0
    Exercise rescheduled for 2012-07-09 00:00:00 +0900

In this case, since the exercise had already been scheduled and was simply a
repetition of a failed exercise, the date matched that which was output
previously.

Finally, we can confirm that there are no more exercises left to practice:

    $ srs queue
    $ srs next-due

Contributing
------------

`srs` is in very early stages and as such there is a _lot_ of work still to do
on it.  Contributions are welcome!

To contribute, fork the project on github and send me a pull request, or email
me a patch.  Please bear the following in mind when making contributions:

 * Try and keep individual commits small and self-contained.  If I feel like
   there is too much going on in a single commit, I may ask you to split it up
   into multiple commits.
 * Please write clear, descriptive commit messages.  These should be formatted
   with a title of `<=` 50 characters, and body text wrapped at 72 characters.
   I am quite particular about this.
 * I come from a pretty heavy C++ background.  Ruby style corrections and
   improvements are very much appreciated!  Please be nice about it.

Copyright
---------

Copyright (c) 2012 Daniel P. Wright.

This software is released under the Simplified BSD Licence.  See LICENCE.md for
further details.

[1]: http://en.wikipedia.org/wiki/Spacing_effect
[2]: http://en.wikipedia.org/wiki/Forgetting_curve
[3]: http://en.wikipedia.org/wiki/Spaced_repetition
[4]: http://en.wikipedia.org/wiki/Graduated_interval_recall
[5]: http://www.supermemo.com/english/ol/sm2.htm
