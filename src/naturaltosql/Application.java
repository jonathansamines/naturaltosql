package naturaltosql;

import java_cup.runtime.Symbol;
import naturaltosql.compiler.LexicalAnalyzer;
import naturaltosql.compiler.SintacticAnalyzer;
import naturaltosql.contexto.ErrorLexico;

public class Application {
	
	@SuppressWarnings("deprecation")
	public static void main(String [] args){
		LexicalAnalyzer lexical = null;
		SintacticAnalyzer syntax = null;
		Symbol result = null;
		try{
	        lexical = new LexicalAnalyzer("Listar Estudiante * donde promedio > 80;");
	        syntax = new SintacticAnalyzer(lexical);
	        result = syntax.parse();
	        System.out.println(result.value);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            
            for(ErrorLexico token : lexical.getNotUsedTokens()){
            	System.out.println("'" + token + "'  ");
            }
        }
	}
}
