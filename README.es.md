# Shindobaddo Nanatsu no Bouken - desensamblado comentado

*(Also [in English](README.md).)*

El desensamblado comentado de **Shindobaddo Nanatsu no Bouken** (シンドバッド７つの冒険, Casio, 1986) para MSX: un cartucho de 16 KB en 0x4000.

- **100 %** del binario explicado: 10.686 bytes de código y 5.698 de datos con nombre, ni un byte sin asignar.
- **40,7 %** del listado comentado, 639 rutinas y etiquetas, ninguna por debajo del 10 % de comentarios.
- El listado se reensambla en la ROM original **byte a byte**.
- El título sale de ejecutar la ROM, cotejado con openMSX; las siete islas, de la RAM que monta la ROM; el alfanje, el salto mortal, el pájaro y el final de una isla, jugados en GIF; las cinco músicas, de su propio motor de sonido e idénticas a openMSX cuadro a cuadro.

La web: <https://antxiko.github.io/Shindobaddo-disassembly/es/>
(en inglés: <https://antxiko.github.io/Shindobaddo-disassembly/>).

## Reproducirlo

La imagen de la ROM no se distribuye. Pon la tuya en la raíz como `sindbad.rom` (sha256 `ea8aeef3...`) y ejecuta `make`. El detalle, en [POR DENTRO](docs/es/POR-DENTRO.md).

## Legal

El juego es de Casio y de sus titulares. La licencia de `LICENSE` cubre solo las herramientas, los comentarios, el análisis y la documentación de aquí. Mira [AVISO-LEGAL.md](AVISO-LEGAL.md).
