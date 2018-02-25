require 'queued_state_machine/invalid_transition'

module QueuedStateMachine
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    attr_reader :initial_state
    
    def inherited(subclass)
      subclass.instance_variable_set("@states", instance_variable_get("@states").dup)
      subclass.instance_variable_set("@initial_state", instance_variable_get("@initial_state"))
      subclass.instance_variable_set("@transitions", instance_variable_get("@transitions").dup)
      subclass.instance_variable_set("@callbacks", instance_variable_get("@callbacks").dup)
    end
    
    def states
      @states ||= []
    end
    
    def transitions
      @transitions ||= []
    end
    
    def callbacks
      @callbacks ||= []
    end
    
    def state(name, initial: false)
      unless transitions.empty? && callbacks.empty?
        raise 'Error: all states must be defined before any transitions of callbacks'
      end
      name = clean_state(name)
      self.initial_state = name if initial
      states << name
      nil
    end
    
    def transition(from: nil, to: nil)
      if block_given?
        raise "Error: transitions do not accept blocks, use 'on_transition'"
      end
      from = clean_state_list(from)
      to = clean_state_list(to)
      missing_state = (from + to).find { |state| !states.include?(state) }
      if missing_state
        raise "Error: state #{missing_state} not defined"
      end
      transitions << {from: from, to: to}
      nil
    end
    
    def on_transition(from: nil, to: nil, &block)
      unless block_given?
        'Error: no callback defined'
      end
      from = clean_state_list(from)
      to = clean_state_list(to)
      missing_state = (from + to).find { |state| !states.include?(state) }
      if missing_state
        raise "Error: state #{missing_state} not defined"
      end
      callbacks << {from: from, to: to, callback: block}
      nil
    end
    
    def clean_state(name)
      name.to_s
    end
    
    def clean_state_list(arg)
      case
      when arg == nil
        states
      when arg.respond_to?(:to_a)
        list = arg
        list.map! {|name| clean_state(name) }
        list
      else
        name = arg
        [clean_state(name)]
      end
    end
    
    def initial_state
      raise 'Error: no initial state set' unless @initial_state
      @initial_state
    end
    
    def initial_state=(name)
      raise 'Error: initial state already set' if @initial_state
      @initial_state = name
    end
    
  end
  
  def initialize
    super
    @state = self.class.initial_state
    @pending_transitions = []
  end
  
  def to(state, quiet: false)
    from = @state
    to = self.class.clean_state(state)
    @pending_transitions << {from: from, to: to, quiet: quiet}
    return if @pending_transitions.length > 1
    loop do
      next_transition = @pending_transitions.first
      break unless next_transition
      @state = next_transition[:to]
      unless next_transition[:quiet]
        process_transition(next_transition[:from], next_transition[:to])
      end
      @pending_transitions.shift
    end
  end
  
  def quietly_to(state)
    to(state, quiet: true)
  end
  
  def at
    @state
  end
  
  def at?(arg)
    list = self.class.clean_state_list(arg)
    raise if list == nil
    list.include?(@state)
  end
  
  private
  
  def process_transition(from, to)
    valid_transitions = self.class.transitions.select do |transition|
      transition[:from].include?(from) && transition[:to].include?(to)
    end
    if valid_transitions.empty?
      raise InvalidTransition, "Error: no valid transition from '#{from}' to '#{to}'"
    end
    valid_callbacks = self.class.callbacks.select do |transition|
      transition[:from].include?(from) && transition[:to].include?(to)
    end
    valid_callbacks.each { |callback| instance_eval(&callback[:callback]) }
  end
  
end
