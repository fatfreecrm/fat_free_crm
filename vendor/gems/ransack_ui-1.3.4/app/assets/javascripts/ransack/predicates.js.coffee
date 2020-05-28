window.Ransack ?= {}

Ransack.predicates =
  eq: 'not_eq'
  cont: 'not_cont'
  matches: 'does_not_match'
  start: 'not_start'
  end: 'not_end'
  present: 'blank'
  null: 'not_null'
  lt: 'gteq'
  gt: 'lteq'
  in: 'not_in'
  true: 'false'

# Setup supported predicates for each column type.
Ransack.type_predicates = {}
((o, f) -> f.call o) Ransack.type_predicates, ->
  @text = @string = ['eq', 'cont', 'matches', 'start', 'end', 'present', 'in']
  @boolean = ['true', 'null']
  @integer = @float = @decimal = ['eq', 'null', 'lt', 'gt', 'in']
  @date = @datetime = @time = ['eq', 'null', 'lt', 'gt']

# Setup input field types for each predicate
Ransack.predicate_inputs = {}
((o, f) -> f.call o) Ransack.predicate_inputs, ->
  @cont = @matches = @start = @end = @in = 'string'
  @present = @null = @true = false
  @eq = @gt = @lt = (type) ->
    switch type
      when 'string','text' then 'string'
      when 'integer','float','decimal' then 'numeric'
      when 'date','datetime','time' then type
      else false # Hide for unhandled types.

# Setup predicates for fixed select options. Includes relevant any/all permutations
Ransack.option_predicates = ['eq', 'eq_any', 'not_eq', 'not_eq_all', 'null', 'not_null']

# Use a tags input for 'in' if Select2 is available
if Select2?
  Ransack.predicate_inputs.in = 'tags'