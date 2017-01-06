package naturaltosql.contexto;

public class ErrorLexico {
	
	public String caracter;
	public int linea;
	public int columna;

	public ErrorLexico(String caracter, int linea, int columna){
		this.caracter = caracter;
		this.linea = linea;
		this.columna = columna;
	}
	
	@Override
	public String toString() {
		return "Caracter no valido : '" + this.caracter + "' en [" + this.linea + ", " + this.columna + "]";
	}
}
