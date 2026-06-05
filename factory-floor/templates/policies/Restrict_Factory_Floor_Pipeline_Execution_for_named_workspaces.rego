# HSF OPA Policy: Restrict Factory Floor Pipeline Execution for named workspaces
package pipeline
import future.keywords.if
import future.keywords.in

###############################################################################
# Important Note: Each restricted pipeline would need to be declared by identifier
# along with workspaces not allowed to be run.
###############################################################################

restricted_workspaces = [
  "harness-pilot-light",
  "harness-solutions-factory",
]

restricted_pipeline_tags = {
  "factory_floor":"true"
}

deny [msg] {
  # Gather all the stages in the document
  stage = input.pipeline.stages[_].stage
  stage.type == "IACM"
  array_contains(restricted_workspaces, stage.spec.workspace)
  verify_enforcement_handlers

  # Foreach match of stage.type, return a message with matching stage identifier.
  msg = sprintf("This pipeline execution for this Workspace (%s) is restricted.", [stage.spec.workspace])
}

deny [msg] {
  # Gather all the stages in the document
  stage = input.pipeline.stages[_].parallel[_].stage
  stage.type == "IACM"
  array_contains(restricted_workspaces, stage.spec.workspace)
  verify_enforcement_handlers

  # Foreach match of stage.type, return a message with matching stage identifier.
  msg = sprintf("This pipeline execution for this Workspace (%s) is restricted.", [stage.spec.workspace])
}

# Rule Verification checks
verify_enforcement_handlers if {
  tmp_output := [return_count_if_elem_in_list(input.pipeline.tags, restricted_pipeline_tags)]
  count([elem | some elem in tmp_output; elem > 0]) > 0
}


#### BEGIN - Pipeline Evaluation Methods ####

return_notated_obj(eval_item) := eval_item.identifier if {
  eval_item.projectIdentifier != ""
} else := concat(".", ["org", eval_item.identifier]) if {
  eval_item.orgIdentifier != ""
} else := concat(".", ["account", eval_item.identifier]) if {
  eval_item.identifier != ""
} else := eval_item

return_count_if_elem_in_list(items, eval_arr) := output if {
  is_array(items)
  return_nonempty_objects(eval_arr)
  output := count([item | some item in items; array_contains(eval_arr, return_notated_obj(item))])
} else := output if {
  is_object(items)
  return_nonempty_objects(eval_arr)
  output := to_number(has_all_keys_and_values(items, eval_arr))
} else := count([item | some item in [items]; array_contains(eval_arr, return_notated_obj(item))])

#### END   - Pipeline Evaluation Methods ####

#### BEGIN - Policy Helper Functions ####

array_contains(arr, elem) if {
  arr[_] = elem
}

has_key(x, k) if {
  _ = x[k]
}

has_all_keys_and_values(truth, check) := true if {
  count([ key | some key,elem in truth; has_key(check, key); elem == check[key]]) == count(object.keys(check))
} else := false

return_nonempty_objects(item) if {
  item != ""
  item != []
  item != {}
}

#### END   - Policy Helper Functions ####
###############################################################################
