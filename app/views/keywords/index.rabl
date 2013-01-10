collection @keywords
extends "keywords/show"

node('_links') { |m| {:self => keyword_path(m)} }