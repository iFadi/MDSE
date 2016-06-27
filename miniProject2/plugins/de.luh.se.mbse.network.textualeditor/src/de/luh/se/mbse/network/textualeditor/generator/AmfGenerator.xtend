/*
 * generated by Xtext 2.9.1
 */
package de.luh.se.mbse.network.textualeditor.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import de.luh.se.mbse.network.textualeditor.amf.Network
import de.luh.se.mbse.network.textualeditor.amf.Channel
import de.luh.se.mbse.network.textualeditor.amf.Statemachine
import de.luh.se.mbse.network.textualeditor.amf.Transition
import de.luh.se.mbse.network.textualeditor.AbstractAmfRuntimeModule
import de.luh.se.mbse.network.textualeditor.amf.State
import de.luh.se.mbse.network.textualeditor.services.AmfGrammarAccess.TransitionElements

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class AmfGenerator extends AbstractGenerator {
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		for (network : resource.allContents.toIterable.filter(Network)) {
			fsa.generateFile(network.eClass.name+".java", network.compile)			
		}
		for (statemachine : resource.allContents.toIterable.filter(Statemachine)) {
			fsa.generateFile(statemachine.name+".java", statemachine.compile)			
		}		
	}
	
	def compile(Network network) 
		'''		  		
  		public class «network.eClass.name» {
  			 // Statemachines in the network
  			«FOR sm : network.statemachine»
  				private «sm.name.toFirstUpper» «sm.name.toFirstLower»;
  			«ENDFOR»
  			// Channels declarations
  			«FOR c : network.channel»
  				«FOR t : c.type»
  					«IF t.getName == "Asynchronous"»
  						public static int «c.name»;  					
  					«ENDIF»
  				«ENDFOR»
  			«ENDFOR»
  			  			  			
  			public static void main(String[] args) {
  				Network «network.eResource.className» = new Network();
  				«network.eResource.className».initialize();
  				
  				System.out.println("Running the network ...");
  				for (int i=0; i<=10; i++) {
  					System.out.println("Step " + i + ":" );
  					«network.eResource.className».makeStep();
  				}
  			}
  			
  			// initialize method
  			public void initialize() {
  				System.out.println("Initializing the network ...");
  				«FOR sm : network.statemachine»
  						«sm.name.toFirstLower» = new «sm.name.toFirstUpper»(); // The initial State is the current state.
  				«ENDFOR»
  				
  				«FOR c : network.channel»
  					«c.name» = 0; // // ASYN channel buffer mapped to zero.
  				«ENDFOR»
  			}
  			
  			// makeStep method
  			public void makeStep() {
  				«FOR sm : network.statemachine»
  					«sm.name.toFirstLower».fireTransition();
  					«FOR t : sm.transition»
  						«t.output»
  					«ENDFOR»
  					System.out.println("«sm.name»: Current State: " + «sm.name.toFirstLower».getCurrentState() + " Channel Buffer: ");
  				«ENDFOR»
  			}
  		}
		'''	
		
	def compile(Statemachine statemachine) {
		'''
		public class «statemachine.name» {
			
			private String currentState;
			
			public «statemachine.name»() {
				 setCurrentState("«statemachine.initialstate.name»");
			}
			
			public String getCurrentState() {
				return currentState;	
			}
			
			public void setCurrentState(String state) {
				currentState = state;	
			}
			  						
			public void fireTransition() {
				«FOR s : statemachine.state»
				if(getCurrentState() == "«s.name»") {
					«FOR t : statemachine.transition»
						«IF t.source.name == s.name»
							if("«t.event.getName»" == "RECEIVE" && Network.«t.channel.name» > 0) {
								setCurrentState("«t.target.name»");
								Network.«t.channel.name»--; }
							else {
								setCurrentState("«t.target.name»");
								Network.«t.channel.name»++; }
						«ENDIF»
					«ENDFOR»
				}
				«ENDFOR»	
			}
		}
		'''	
		}
		
		
	def enabledTransitions(Transition transition)
		'''

		'''
	
	def boolean enabled(Transition transition) {
		
		return false;
	}
		
	def fireTransition(State state, Transition transition)
		'''
		if(getCurrentState() == "«state.name»") {
			«transition.enabledTransitions»
		}	
		'''		
		
	def className(Resource res) {
  		var name = res.URI.lastSegment
  		name.substring(0, name.indexOf('.'))
	 }

	def output(Transition transition) 
		'''
		«var sync = "Asynchronous"»
		«IF transition.channel.name == "Synchronous"»
			«sync = "Synchronous"»
		«ENDIF»
		«val stateMachine = transition.eContainer as Statemachine»
		System.out.println("«stateMachine.name»: «transition.source.name» ==> «transition.target.name» : [«sync»]«transition.channel.name»");
		'''
		
	def channelTokensGreaterThanZero(Transition transition) 
		'''
«««		«network.eClass.name.toFirstUpper»Main.get«transition.channel.name.toFirstUpper»() > 0
		'''
}

