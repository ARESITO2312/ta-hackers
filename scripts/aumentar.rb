class NumeroIncrementador
  INTERVAL_MIN = 300 # Intervalo mínimo en segundos
  INTERVAL_ADD = 120 # Intervalo adicional aleatorio en segundos
  NUMERO_INICIAL = 10.5 # Número inicial real
  CANTIDAD_AUMENTAR = 2.8 # Cantidad a aumentar

  def main
    loop do
      numero_actual = NUMERO_INICIAL
      numero_actual += CANTIDAD_AUMENTAR
      puts "El número incrementado es: #{numero_actual}"
      sleep(INTERVAL_MIN + rand(INTERVAL_ADD))
    end
  end
end

# Ejecutar el script
script = NumeroIncrementador.new
script.main