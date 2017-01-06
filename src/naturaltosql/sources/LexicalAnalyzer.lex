// Primera sección de JLex
// Código copiado literalmente a la clase generadora de tokens
package naturaltosql.compiler;


import java_cup.runtime.Symbol;
import java_cup.sym;
import java.util.ArrayList;
import java.lang.String;
import java.io.StringReader;
import naturaltosql.contexto.ErrorLexico;

%%

%{

	ArrayList<ErrorLexico> tokensNoValidos = null;
	
	
	public ArrayList<ErrorLexico> getNotUsedTokens(){
		return this.tokensNoValidos;
	}
	
	public void agregarTokenNoValido(String token, int linea, int columna) {
		this.tokensNoValidos.add(new ErrorLexico(token, linea, columna));
	}
	
	public LexicalAnalyzer(String input) {
    	StringReader reader = new StringReader(input.toLowerCase());
    	
    	this.tokensNoValidos = new ArrayList<ErrorLexico>();
    	this.zzReader = reader; // zzReader es un objeto especial de lex
 	}
%}

// Inicio de la segunda sección de JLex
// Directivas globales, macros y estados
%class LexicalAnalyzer // Define el nombre de la clase
%full // habilita codificación de caracteres completa
%line // habilita el cursor de número de linea
%column // habilita el cursor para el número de columna
%char  // habilita la captura del caracter actual
%cup // habilita la compatibilidad con cup (la clase creada implementa una interfaz de cup)
%public // cambia el modificador de acceso de la clase resultante

// Macros que definen expresiones regulares para la captura de tokens
saltolinea=[\n\r\t]
espacio=[\s]
saltoespacio={saltolinea} | {espacio}
entero=[0-9]+
real=[0-9]+\.?[0-9]+ 
cadena=[A-Za-z_]+

// Estados de la aplicación
// Operaciones principales permitidas por el analizador léxico
%state LISTAR, INSERTAR, ACTUALIZAR, ELIMINAR, CREAR_TABLA
%state NOMBRE_TABLA, DONDE, COLUMNAS
%state DEFINICION_CAMPO, TIPO_DATO_CAMPO
%state VALOR_CON_COMA, CAMPO_CON_VALOR, VALOR_CAMPO

// Sección final de JLex
// Define los patrones de captura de tokens
%%

// estado inicial de lex
// definición del token para seleccionar
<YYINITIAL>{saltoespacio}*    	{/* ignorar simbolo */}

// definición de las operaciones básicas aceptadas por el lenguaje
// creacion de tabla
<YYINITIAL>crear{espacio}*:		{ yybegin(NOMBRE_TABLA); return new Symbol(Symbols.TK_CREAR_TABLA); }

// atributos de la tabla
<YYINITIAL>atributos{espacio}*:	{ yybegin(DEFINICION_CAMPO); return new Symbol(Symbols.TK_ATRIBUTOS); }

// operaciones CRUD
<YYINITIAL>listar		{ yybegin(NOMBRE_TABLA); return new Symbol(Symbols.TK_LISTAR); }
<YYINITIAL>insertar		{ yybegin(NOMBRE_TABLA); return new Symbol(Symbols.TK_ACTUALIZAR); }
<YYINITIAL>borrar		{ yybegin(NOMBRE_TABLA); return new Symbol(Symbols.TK_BORRAR); }
<YYINITIAL>actualizar	{ yybegin(NOMBRE_TABLA); return new Symbol(Symbols.TK_ACTUALIZAR); }

// condiciones de filtrado
<YYINITIAL>donde		{ yybegin(DONDE); return new Symbol(Symbols.TK_DONDE); }

// finalización de la sentencia
<YYINITIAL>;			{ return new Symbol(Symbols.TK_FIN_SENTENCIA); }
<YYINITIAL>.			{ this.agregarTokenNoValido(yytext(), yyline, yychar); }

// definición de los nombres de las tablas válidas
<NOMBRE_TABLA>{saltoespacio}*	{}
<NOMBRE_TABLA>estudiante:?		{ return new Symbol(Symbols.TK_TABLA_ESTUDIANTE); }
<NOMBRE_TABLA>.								{ this.agregarTokenNoValido(yytext(), yyline, yychar); }

// definicion de los atributos (parametros de creación de tablas)
<DEFINICION_CAMPO>{espacio}*	{ /* ignorar simbolo */ }
<DEFINICION_CAMPO>nombre		{ yybegin(TIPO_DATO_CAMPO); return new Symbol(Symbols.TK_NOMBRE); }
<DEFINICION_CAMPO>carnet		{ yybegin(TIPO_DATO_CAMPO); return new Symbol(Symbols.TK_CARNET); }
<DEFINICION_CAMPO>promedio		{ yybegin(TIPO_DATO_CAMPO); return new Symbol(Symbols.TK_PROMEDIO); }
<DEFINICION_CAMPO>telefono		{ yybegin(TIPO_DATO_CAMPO); return new Symbol(Symbols.TK_TELEFONO); }
<DEFINICION_CAMPO>carrera		{ yybegin(TIPO_DATO_CAMPO); return new Symbol(Symbols.TK_CARRERA); }
<DEFINICION_CAMPO>,				{ return new Symbol(Symbols.TK_COMA); }
<DEFINICION_CAMPO>.				{ this.agregarTokenNoValido(yytext(), yyline, yychar); }

// Tipos de datos aceptados para los campos
<TIPO_DATO_CAMPO>{espacio}*	{ /* ignorar simbolo */ }
<TIPO_DATO_CAMPO>entero		{ return new Symbol(Symbols.TK_ENTERO_DEFINICION); }
<TIPO_DATO_CAMPO>real		{ return new Symbol(Symbols.TK_REAL_DEFINICION); }
<TIPO_DATO_CAMPO>cadena		{ return new Symbol(Symbols.TK_CADENA_DEFINICION); }
<TIPO_DATO_CAMPO>.			{ this.agregarTokenNoValido(yytext(), yyline, yychar); }

// valores para la sentencia INSERT
<VALOR_CON_COMA>{cadena}			{ return new Symbol(Symbols.TK_CADENA, new String(yytext())); }
<VALOR_CON_COMA>{entero}			{ return new Symbol(Symbols.TK_ENTERO, Integer.parseInt(yytext())); }
<VALOR_CON_COMA>{real}				{ return new Symbol(Symbols.TK_REAL, Double.parseDouble(yytext())); }
<VALOR_CON_COMA>,					{ return new Symbol(Symbols.TK_COMA); }
<VALOR_CON_COMA>.					{ this.agregarTokenNoValido(yytext(), yyline, yychar); }

// actualización de campos en UPDATE
<CAMPO_CON_VALOR>{espacio}*					{/* ignorar simbolo */ }
<CAMPO_CON_VALOR>nombre{espacio}?			{ return new Symbol(Symbols.TK_NOMBRE); }
<CAMPO_CON_VALOR>carnet{espacio}?			{ return new Symbol(Symbols.TK_CARNET); }
<CAMPO_CON_VALOR>promedio{espacio}?			{ return new Symbol(Symbols.TK_PROMEDIO); }
<CAMPO_CON_VALOR>telefono{espacio}?			{ return new Symbol(Symbols.TK_TELEFONO); }
<CAMPO_CON_VALOR>carrera{espacio}?			{ return new Symbol(Symbols.TK_CARRERA); }
<CAMPO_CON_VALOR>={espacio}?				{ yybegin(VALOR_CAMPO); return new Symbol(Symbols.TK_IGUAL); }
<CAMPO_CON_VALOR>,							{ return new Symbol(Symbols.TK_COMA); }
<CAMPO_CON_VALOR>.							{ this.agregarTokenNoValido(yytext(), yyline, yychar); }


// Definición de las columnas
<COLUMNAS>{saltoespacio}*          		{/* ignorar simbolo */}
<COLUMNAS>nombre					{ return new Symbol(Symbols.TK_NOMBRE); }
<COLUMNAS>carnet					{ return new Symbol(Symbols.TK_CARNET); }
<COLUMNAS>telefono					{ return new Symbol(Symbols.TK_TELEFONO); }
<COLUMNAS>carrera					{ return new Symbol(Symbols.TK_CARRERA); }
<COLUMNAS>\*						{ return new Symbol(Symbols.TK_TODOS); }
<COLUMNAS>,							{ return new Symbol(Symbols.TK_COMA); }
<COLUMNAS>.							{ this.agregarTokenNoValido(yytext(), yyline, yychar); }

// posibles campos de la tabla para el filtrado de datos
<DONDE>{saltoespacio}+			{/* ignorar simbolo */}
<DONDE>y{espacio}?				{ return new Symbol(Symbols.TK_Y); }
<DONDE>o{espacio}?				{ return new Symbol(Symbols.TK_O); }
<DONDE>nombre{espacio}?			{ return new Symbol(Symbols.TK_NOMBRE); }
<DONDE>carnet{espacio}?			{ return new Symbol(Symbols.TK_CARNET); }
<DONDE>promedio{espacio}?		{ return new Symbol(Symbols.TK_PROMEDIO); }
<DONDE>telefono{espacio}?		{ return new Symbol(Symbols.TK_TELEFONO); }
<DONDE>carrera{espacio}?		{ return new Symbol(Symbols.TK_CARRERA); }
<DONDE>>{espacio}?				{ yybegin(VALOR_CAMPO); return new Symbol(Symbols.TK_MAYOR); }
<DONDE><{espacio}?				{ yybegin(VALOR_CAMPO); return new Symbol(Symbols.TK_MENOR); }
<DONDE>>={espacio}?				{ yybegin(VALOR_CAMPO); return new Symbol(Symbols.TK_MAYOR_IGUAL); }
<DONDE><={espacio}?  			{ yybegin(VALOR_CAMPO); return new Symbol(Symbols.TK_MENOR_IGUAL); }
<DONDE>={espacio}? 			 	{ yybegin(VALOR_CAMPO); return new Symbol(Symbols.TK_IGUAL); }
<DONDE>!={espacio}?			 	{ yybegin(VALOR_CAMPO); return new Symbol(Symbols.TK_DIFERENTE); } 
<DONDE>.						{ this.agregarTokenNoValido(yytext(), yyline, yychar); }

// posibles valores para un campo
<VALOR_CAMPO>{cadena}		{ return new Symbol(Symbols.TK_CADENA,  new String (yytext())); }
<VALOR_CAMPO>{entero}		{ return new Symbol(Symbols.TK_ENTERO, Integer.parseInt(yytext())); }
<VALOR_CAMPO>{real}			{ return new Symbol(Symbols.TK_REAL, Double.parseDouble(yytext())); }
<VALOR_CAMPO>.				{ this.agregarTokenNoValido(yytext(), yyline, yychar); }