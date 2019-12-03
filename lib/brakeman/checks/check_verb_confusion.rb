require 'brakeman/checks/base_check'

class Brakeman::CheckVerbConfusion < Brakeman::BaseCheck
  Brakeman::Checks.add self

  @description = ""

  #Process calls
  def run_check
    calls = tracker.find_call(target: :request, methods: [:get?]) 

    calls.each do |call|
      process_result call
    end
  end

  def process_result result
    @current_result = result
    @matched_call = result[:call]
    klass = tracker.find_class(result[:location][:class])

    # TODO: abstract into tracker.find_location ?
    if klass.nil?
      Brakeman.debug "No class found: #{result[:location][:class]}"
      return
    end

    method = klass.get_method(result[:location][:method])

    if method.nil?
      Brakeman.debug "No method found: #{result[:location][:method]}"
      return
    end

    process method[:src]
  end

  def process_if exp
    if exp.condition == @matched_call
      # Found `if request.get?`

      # Only `else`, not `elsif`
      if not node_type? exp.else_clause, :if
        warn_about_result @current_result
      end
    end

    exp
  end

  #Warns if eval includes user input
  def warn_about_result result
    return unless original? result

    confidence = :weak

    warn :result => result,
      :warning_type => "Dangerous Eval",
      :warning_code => :code_eval,
      :message => "Potential HTTP verb confusion",
      :confidence => confidence
  end
end
