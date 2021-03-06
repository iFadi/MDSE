package de.luh.se.mbse.network.javacode;
import java.util.ArrayList;

public class Statemachine {

	private String name;
	private ArrayList<State> states;
	private Transition transition;
	private State currentState;
	private State initialState;
	
	public Statemachine() {
		
	}
	
	public Statemachine(String name, State initialState) {
		setInitialState(initialState);
		setName(name);
		// The current state of each state machine is its initial state.
		setCurrentState(getInitialState());
	}

	public State getCurrentState() {
		return currentState;
	}

	public void setCurrentState(State currentState) {
		this.currentState = currentState;
	}

	public State getInitialState() {
		return initialState;
	}

	public void setInitialState(State initialState) {
		this.initialState = initialState;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public ArrayList<State> getStates() {
		return states;
	}

	public void setStates(ArrayList<State> states) {
		this.states = states;
	}
	
	public void addState(State state) {
		this.getStates().add(state);
	}

	public Transition getTransition() {
		return transition;
	}

	public void setTransition(Transition transition) {
		this.transition = transition;
	}
}
