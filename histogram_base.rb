require 'ruby-tf-idf'

corpus = 
[
'A big enough hammer can usually fix anything',
'A bird in the hand is a big mistake .',
'A bird in the hand is better than one overhead!',
'A career is a job that takes about 20 more hours a week.',
'A clean desk is a sign of a cluttered desk drawer.',
'A cynic smells flowers and looks for the casket.'
]

limit = 3 #restrict to the top 3 relevant words per document
exclude_stop_words = false


@t = RubyTfIdf::TfIdf.new(corpus,limit,exclude_stop_words)
output =  @t.tf_idf
puts output
