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
  			«FOR sm : network.statemachine»
  				private «sm.name.toFirstUpper» «sm.name.toFirstLower»;
  			«ENDFOR»
  			
  			«FOR c : network.channel»
  				«FOR t : c.type»
  					«IF t.getName == "Asynchronous"»
  						private int «c.name»;
  						public int get«c.name.toFirstUpper»() {
  							return «c.name»;	
  						}
  						public void increament«c.name.toFirstUpper»() {
  							«c.name»++;	
  						}
  						public void decrement«c.name.toFirstUpper»() {
  						  	«c.name»--;	
  						}
  					«ELSE»
  					
  					«ENDIF»
  				«ENDFOR»
  			«ENDFOR»
  			  			  			
  			public static void main(String[] args) {
  				Network «network.eResource.className» = new Network();
  				«network.eResource.className».initialize();
  				System.out.println("Making Steps ...");
  				// make Steps
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
  						System.out.println("Statemachine: «sm.name» --- Current State: " + «sm.name.toFirstLower».getCurrentState());		
  				«ENDFOR»
  				«FOR c : network.channel»
  					«c.name» = 0; // // ASYN channel buffer mapped to zero.
  					System.out.println("«c.name» Buffer: " + get«c.name.toFirstUpper»());
  				«ENDFOR»
  				System.out.println("");
  			}
  			
  			// makeStep method
  			public void makeStep() {
  				//fireAsyncSendMessage();
  				//fireSyncMessage();
  			}
  		}
		'''	
		
	def compile(Statemachine statemachine) {
		'''
		public class «statemachine.name» {
			
			private String currentState = "«statemachine.initialstate.name»";
			
			public «statemachine.name»() {
					
			}
			
			public String getCurrentState() {
				return currentState;	
			}
			  						
			public void fireTransition() {
				«FOR s : statemachine.state»
					«s.fireTransition»
					«FOR t : statemachine.transition»
						«t.generateTransition»
					«ENDFOR»
				«ENDFOR»	
			}
		}
		'''	
		}
		
		
	def generateTransition(Transition trnasition)
		'''
		«trnasition.output»
		'''
	
	def fireTransition(State state)
		'''
		if(currentState == "«state.name»") {

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
		System.out.println("«stateMachine.name» : «sync» «transition.source.name» -> «transition.target.name» : «transition.channel.name»");
		'''
}

