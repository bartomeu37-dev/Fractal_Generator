# Resultados de implementación

## Resultados Núcleos

Frecuencia de reloj de 100 MHz

### FSM

| NºPíxeles | NºCiclos   | Tiempo Total (ms) | Ciclos medio por turno |
|-----------|-----------|-------------------|------------------------|
| 518400    | 51834192  | 518,34192         | 99,8                   |

#### Recursos usados

##### Slice LUTs

| Site Type              | Used | Fixed | Prohibited | Available | Util% |
|------------------------|------|-------|------------|-----------|-------|
| Slice LUTs*            | 140  | 0     | 0          | 63400     | 0.22  |
|   LUT as Logic         | 140  | 0     | 0          | 63400     | 0.22  |
|   LUT as Memory        | 0    | 0     | 0          | 19000     | 0.00  |
| Slice Registers        | 193  | 0     | 0          | 126800    | 0.15  |
|   Register as Flip Flop| 193  | 0     | 0          | 126800    | 0.15  |
|   Register as Latch    | 0    | 0     | 0          | 126800    | 0.00  |
| F7 Muxes               | 0    | 0     | 0          | 31700     | 0.00  |
| F8 Muxes               | 0    | 0     | 0          | 15850     | 0.00  |
| Unique Control Sets    | 11   |       | 0          | 15850     | 0.07  |

##### DSPs

| Site Type   | Used | Fixed | Prohibited | Available | Util% |
|-------------|------|-------|------------|-----------|-------|
| DSPs        | 3    | 0     | 0          | 240       | 1.25  |
|   DSP48E1 only | 3 |       |            |           |       |

##### Clocking

| Site Type   | Used | Fixed | Prohibited | Available | Util% |
|-------------|------|-------|------------|-----------|-------|
| BUFGCTRL    | 1    | 0     | 0          | 32        | 3.13  |
| BUFIO       | 0    | 0     | 0          | 24        | 0.00  |
| MMCME2_ADV  | 0    | 0     | 0          | 6         | 0.00  |
| PLLE2_ADV   | 0    | 0     | 0          | 6         | 0.00  |
| BUFMRCE     | 0    | 0     | 0          | 12        | 0.00  |
| BUFHCE      | 0    | 0     | 0          | 96        | 0.00  |
| BUFR        | 0    | 0     | 0          | 24        | 0.00  |

##### Primitivas

| Ref Name | Used | Functional Category |
|----------|------|---------------------|
| FDRE     | 157  | Flop & Latch        |
| LUT4     | 64   | LUT                 |
| LUT2     | 40   | LUT                 |
| CARRY4   | 40   | CarryLogic          |
| LUT5     | 30   | LUT                 |
| OBUF     | 28   | IO                  |
| FDSE     | 25   | Flop & Latch        |
| LUT1     | 13   | LUT                 |
| LUT3     | 10   | LUT                 |
| FDCE     | 10   | Flop & Latch        |
| LUT6     | 8    | LUT                 |
| DSP48E1  | 3    | Block Arithmetic    |
| IBUF     | 2    | IO                  |
| FDPE     | 1    | Flop & Latch        |
| BUFG     | 1    | Clock               |

---

### OO

| NºPíxeles | NºCiclos  | Tiempo Total (ms) | Ciclos medio por turno |
|-----------|----------|-------------------|------------------------|
| 518400    | 21511118 | 215               | 41,5                   |

#### Recursos usados

##### Slice LUTs

| Site Type              | Used | Fixed | Prohibited | Available | Util% |
|------------------------|------|-------|------------|-----------|-------|
| Slice LUTs*            | 203  | 0     | 0          | 63400     | 0.32  |
|   LUT as Logic         | 203  | 0     | 0          | 63400     | 0.32  |
|   LUT as Memory        | 0    | 0     | 0          | 19000     | 0.00  |
| Slice Registers        | 254  | 0     | 0          | 126800    | 0.20  |
|   Register as Flip Flop| 254  | 0     | 0          | 126800    | 0.20  |
|   Register as Latch    | 0    | 0     | 0          | 126800    | 0.00  |
| F7 Muxes               | 0    | 0     | 0          | 31700     | 0.00  |
| F8 Muxes               | 0    | 0     | 0          | 15850     | 0.00  |
| Unique Control Sets    | 8    |       | 0          | 15850     | 0.05  |

##### Control Sets

| Total | Clock Enable | Synchronous | Asynchronous |
|-------|--------------|-------------|--------------|
| 0     | _            | -           | -            |
| 0     | _            | -           | Set          |
| 0     | _            | -           | Reset        |
| 0     | _            | Set         | -            |
| 0     | _            | Reset       | -            |
| 0     | Yes          | -           | -            |
| 1     | Yes          | -           | Set          |
| 181   | Yes          | -           | Reset        |
| 25    | Yes          | Set         | -            |
| 47    | Yes          | Reset       | -            |

##### Memory

| Site Type        | Used | Fixed | Prohibited | Available | Util% |
|------------------|------|-------|------------|-----------|-------|
| Block RAM Tile   | 0    | 0     | 0          | 135       | 0.00  |
|   RAMB36/FIFO*   | 0    | 0     | 0          | 135       | 0.00  |
|   RAMB18         | 0    | 0     | 0          | 270       | 0.00  |

> \* Nota: Cada tile de Block RAM solo dispone de una lógica FIFO y, por tanto, solo puede albergar un FIFO36E1 o un FIFO18E1. Sin embargo, si un FIFO18E1 ocupa un tile, ese tile aún puede albergar un RAMB18E1.

##### DSPs

| Site Type   | Used | Fixed | Prohibited | Available | Util% |
|-------------|------|-------|------------|-----------|-------|
| DSPs        | 3    | 0     | 0          | 240       | 1.25  |
|   DSP48E1 only | 3 |       |            |           |       |

##### IO and GT Specific

| Site Type                       | Used | Fixed | Prohibited | Available | Util% |
|---------------------------------|------|-------|------------|-----------|-------|
| Bonded IOB                      | 74   | 0     | 0          | 210       | 35.24 |
| Bonded IPADs                    | 0    | 0     | 0          | 2         | 0.00  |
| PHY_CONTROL                     | 0    | 0     | 0          | 6         | 0.00  |
| PHASER_REF                      | 0    | 0     | 0          | 6         | 0.00  |
| OUT_FIFO                        | 0    | 0     | 0          | 24        | 0.00  |
| IN_FIFO                         | 0    | 0     | 0          | 24        | 0.00  |
| IDELAYCTRL                      | 0    | 0     | 0          | 6         | 0.00  |
| IBUFDS                          | 0    | 0     | 0          | 202       | 0.00  |
| PHASER_OUT/PHASER_OUT_PHY       | 0    | 0     | 0          | 24        | 0.00  |
| PHASER_IN/PHASER_IN_PHY         | 0    | 0     | 0          | 24        | 0.00  |
| IDELAYE2/IDELAYE2_FINEDELAY     | 0    | 0     | 0          | 300       | 0.00  |
| ILOGIC                          | 0    | 0     | 0          | 210       | 0.00  |
| OLOGIC                          | 0    | 0     | 0          | 210       | 0.00  |

##### Clocking

| Site Type   | Used | Fixed | Prohibited | Available | Util% |
|-------------|------|-------|------------|-----------|-------|
| BUFGCTRL    | 1    | 0     | 0          | 32        | 3.13  |
| BUFIO       | 0    | 0     | 0          | 24        | 0.00  |
| MMCME2_ADV  | 0    | 0     | 0          | 6         | 0.00  |
| PLLE2_ADV   | 0    | 0     | 0          | 6         | 0.00  |
| BUFMRCE     | 0    | 0     | 0          | 12        | 0.00  |
| BUFHCE      | 0    | 0     | 0          | 96        | 0.00  |
| BUFR        | 0    | 0     | 0          | 24        | 0.00  |

##### Specific Feature

| Site Type   | Used | Fixed | Prohibited | Available | Util% |
|-------------|------|-------|------------|-----------|-------|
| BSCANE2     | 0    | 0     | 0          | 4         | 0.00  |
| CAPTUREE2   | 0    | 0     | 0          | 1         | 0.00  |
| DNA_PORT    | 0    | 0     | 0          | 1         | 0.00  |
| EFUSE_USR   | 0    | 0     | 0          | 1         | 0.00  |
| FRAME_ECCE2 | 0    | 0     | 0          | 1         | 0.00  |
| ICAPE2      | 0    | 0     | 0          | 2         | 0.00  |
| PCIE_2_1    | 0    | 0     | 0          | 1         | 0.00  |
| STARTUPE2   | 0    | 0     | 0          | 1         | 0.00  |
| XADC        | 0    | 0     | 0          | 1         | 0.00  |

##### Primitivas

| Ref Name | Used | Functional Category |
|----------|------|---------------------|
| FDCE     | 181  | Flop & Latch        |
| LUT5     | 85   | LUT                 |
| LUT6     | 50   | LUT                 |
| FDRE     | 47   | Flop & Latch        |
| IBUF     | 46   | IO                  |
| CARRY4   | 41   | CarryLogic          |
| LUT4     | 37   | LUT                 |
| LUT2     | 34   | LUT                 |
| OBUF     | 28   | IO                  |
| FDSE     | 25   | Flop & Latch        |
| LUT3     | 20   | LUT                 |
| LUT1     | 7    | LUT                 |
| DSP48E1  | 3    | Block Arithmetic    |
| FDPE     | 1    | Flop & Latch        |
| BUFG     | 1    | Clock               |

---

### IO

| NºPíxeles | NºCiclos  | Tiempo Total (ms) | Ciclos medio por turno |
|-----------|----------|-------------------|------------------------|
| 518400    | 11067453 | 110               | 21,3                   |

#### Recursos usados

##### Slice LUTs

| Site Type              | Used | Fixed | Prohibited | Available | Util% |
|------------------------|------|-------|------------|-----------|-------|
| Slice LUTs*            | 202  | 0     | 0          | 63400     | 0.32  |
|   LUT as Logic         | 202  | 0     | 0          | 63400     | 0.32  |
|   LUT as Memory        | 0    | 0     | 0          | 19000     | 0.00  |
| Slice Registers        | 287  | 0     | 0          | 126800    | 0.23  |
|   Register as Flip Flop| 287  | 0     | 0          | 126800    | 0.23  |
|   Register as Latch    | 0    | 0     | 0          | 126800    | 0.00  |
| F7 Muxes               | 0    | 0     | 0          | 31700     | 0.00  |
| F8 Muxes               | 0    | 0     | 0          | 15850     | 0.00  |
| Unique Control Sets    | 9    |       | 0          | 15850     | 0.06  |

> \* Advertencia: El conteo final de LUTs, después de optimizaciones físicas e implementación completa, suele ser menor. Ejecute `opt_design` después de la síntesis, si no se ha hecho, para obtener un conteo más realista.  
> Advertencia: El valor de LUT está ajustado para tener en cuenta la combinación de LUTs.  
> Advertencia: Para cualquier cambio ECO, ejecute `place_design` si hay instancias sin colocar.  
> \*\* Nota: Los conjuntos de control disponibles se calculan como Slice * 1. Consulte el informe de conjuntos de control para más información.

##### Control Sets

| Total | Clock Enable | Synchronous | Asynchronous |
|-------|--------------|-------------|--------------|
| 0     | _            | -           | -            |
| 0     | _            | -           | Set          |
| 0     | _            | -           | Reset        |
| 0     | _            | Set         | -            |
| 0     | _            | Reset       | -            |
| 0     | Yes          | -           | -            |
| 3     | Yes          | -           | Set          |
| 223   | Yes          | -           | Reset        |
| 12    | Yes          | Set         | -            |
| 49    | Yes          | Reset       | -            |

##### Memory

| Site Type        | Used | Fixed | Prohibited | Available | Util% |
|------------------|------|-------|------------|-----------|-------|
| Block RAM Tile   | 0    | 0     | 0          | 135       | 0.00  |
|   RAMB36/FIFO*   | 0    | 0     | 0          | 135       | 0.00  |
|   RAMB18         | 0    | 0     | 0          | 270       | 0.00  |

> \* Nota: Cada tile de Block RAM solo dispone de una lógica FIFO y, por tanto, solo puede albergar un FIFO36E1 o un FIFO18E1. Sin embargo, si un FIFO18E1 ocupa un tile, ese tile aún puede albergar un RAMB18E1.

##### DSPs

| Site Type   | Used | Fixed | Prohibited | Available | Util% |
|-------------|------|-------|------------|-----------|-------|
| DSPs        | 3    | 0     | 0          | 240       | 1.25  |
|   DSP48E1 only | 3 |       |            |           |       |

##### IO and GT Specific

| Site Type                       | Used | Fixed | Prohibited | Available | Util% |
|---------------------------------|------|-------|------------|-----------|-------|
| Bonded IOB                      | 88   | 0     | 0          | 210       | 41.90 |
| Bonded IPADs                    | 0    | 0     | 0          | 2         | 0.00  |
| PHY_CONTROL                     | 0    | 0     | 0          | 6         | 0.00  |
| PHASER_REF                      | 0    | 0     | 0          | 6         | 0.00  |
| OUT_FIFO                        | 0    | 0     | 0          | 24        | 0.00  |
| IN_FIFO                         | 0    | 0     | 0          | 24        | 0.00  |
| IDELAYCTRL                      | 0    | 0     | 0          | 6         | 0.00  |
| IBUFDS                          | 0    | 0     | 0          | 202       | 0.00  |
| PHASER_OUT/PHASER_OUT_PHY       | 0    | 0     | 0          | 24        | 0.00  |
| PHASER_IN/PHASER_IN_PHY         | 0    | 0     | 0          | 24        | 0.00  |
| IDELAYE2/IDELAYE2_FINEDELAY     | 0    | 0     | 0          | 300       | 0.00  |
| ILOGIC                          | 0    | 0     | 0          | 210       | 0.00  |
| OLOGIC                          | 0    | 0     | 0          | 210       | 0.00  |

##### Clocking

| Site Type   | Used | Fixed | Prohibited | Available | Util% |
|-------------|------|-------|------------|-----------|-------|
| BUFGCTRL    | 1    | 0     | 0          | 32        | 3.13  |
| BUFIO       | 0    | 0     | 0          | 24        | 0.00  |
| MMCME2_ADV  | 0    | 0     | 0          | 6         | 0.00  |
| PLLE2_ADV   | 0    | 0     | 0          | 6         | 0.00  |
| BUFMRCE     | 0    | 0     | 0          | 12        | 0.00  |
| BUFHCE      | 0    | 0     | 0          | 96        | 0.00  |
| BUFR        | 0    | 0     | 0          | 24        | 0.00  |

##### Specific Feature

| Site Type   | Used | Fixed | Prohibited | Available | Util% |
|-------------|------|-------|------------|-----------|-------|
| BSCANE2     | 0    | 0     | 0          | 4         | 0.00  |
| CAPTUREE2   | 0    | 0     | 0          | 1         | 0.00  |
| DNA_PORT    | 0    | 0     | 0          | 1         | 0.00  |
| EFUSE_USR   | 0    | 0     | 0          | 1         | 0.00  |
| FRAME_ECCE2 | 0    | 0     | 0          | 1         | 0.00  |
| ICAPE2      | 0    | 0     | 0          | 2         | 0.00  |
| PCIE_2_1    | 0    | 0     | 0          | 1         | 0.00  |
| STARTUPE2   | 0    | 0     | 0          | 1         | 0.00  |
| XADC        | 0    | 0     | 0          | 1         | 0.00  |

##### Primitivas

| Ref Name | Used | Functional Category |
|----------|------|---------------------|
| FDCE     | 223  | Flop & Latch        |
| LUT4     | 106  | LUT                 |
| LUT2     | 101  | LUT                 |
| LUT3     | 66   | LUT                 |
| FDRE     | 49   | Flop & Latch        |
| CARRY4   | 48   | CarryLogic          |
| IBUF     | 47   | IO                  |
| OBUF     | 41   | IO                  |
| LUT5     | 31   | LUT                 |
| LUT6     | 15   | LUT                 |
| FDSE     | 12   | Flop & Latch        |
| LUT1     | 3    | LUT                 |
| FDPE     | 3    | Flop & Latch        |
| DSP48E1  | 3    | Block Arithmetic    |
| BUFG     | 1    | Clock               |

---

### 80 Núcleos IO

| NºPíxeles | NºCiclos | Tiempo Total (ms) | Ciclos medio por turno |
|-----------|----------|-------------------|------------------------|
| 518400    | 930411   | 9,3               | 1,79                   |

#### Recursos usados

##### Slice LUTs

| Site Type              | Used  | Fixed | Prohibited | Available | Util%  |
|------------------------|-------|-------|------------|-----------|--------|
| Slice LUTs*            | 14673 | 0     | 0          | 63400     | 23.14  |
|   LUT as Logic         | 14673 | 0     | 0          | 63400     | 23.14  |
|   LUT as Memory        | 0     | 0     | 0          | 19000     | 0.00   |
| Slice Registers        | 19250 | 0     | 0          | 126800    | 15.18  |
|   Register as Flip Flop| 19250 | 0     | 0          | 126800    | 15.18  |
|   Register as Latch    | 0     | 0     | 0          | 126800    | 0.00   |
| F7 Muxes               | 80    | 0     | 0          | 31700     | 0.25   |
| F8 Muxes               | 32    | 0     | 0          | 15850     | 0.20   |
| Unique Control Sets    | 563   |       | 0          | 15850     | 3.55   |

> \* Advertencia: El conteo final de LUTs, después de optimizaciones físicas e implementación completa, suele ser menor. Ejecute `opt_design` después de la síntesis, si no se ha hecho, para obtener un conteo más realista.  
> Advertencia: El valor de LUT está ajustado para tener en cuenta la combinación de LUTs.  
> Advertencia: Para cualquier cambio ECO, ejecute `place_design` si hay instancias sin colocar.  
> \*\* Nota: Los conjuntos de control disponibles se calculan como Slice * 1. Consulte el informe de conjuntos de control para más información.

##### Control Sets

| Total | Clock Enable | Synchronous | Asynchronous |
|-------|--------------|-------------|--------------|
| 0     | _            | -           | -            |
| 0     | _            | -           | Set          |
| 0     | _            | -           | Reset        |
| 0     | _            | Set         | -            |
| 0     | _            | Reset       | -            |
| 0     | Yes          | -           | -            |
| 320   | Yes          | -           | Set          |
| 14370 | Yes          | -           | Reset        |
| 1008  | Yes          | Set         | -            |
| 3552  | Yes          | Reset       | -            |

##### Memory

| Site Type        | Used | Fixed | Prohibited | Available | Util% |
|------------------|------|-------|------------|-----------|-------|
| Block RAM Tile   | 0    | 0     | 0          | 135       | 0.00  |
|   RAMB36/FIFO*   | 0    | 0     | 0          | 135       | 0.00  |
|   RAMB18         | 0    | 0     | 0          | 270       | 0.00  |

> \* Nota: Cada tile de Block RAM solo dispone de una lógica FIFO y, por tanto, solo puede albergar un FIFO36E1 o un FIFO18E1. Sin embargo, si un FIFO18E1 ocupa un tile, ese tile aún puede albergar un RAMB18E1.

##### DSPs

| Site Type   | Used | Fixed | Prohibited | Available | Util%  |
|-------------|------|-------|------------|-----------|--------|
| DSPs        | 240  | 0     | 0          | 240       | 100.00 |
|   DSP48E1 only | 240 |       |            |           |        |

##### IO and GT Specific

| Site Type                       | Used | Fixed | Prohibited | Available | Util% |
|---------------------------------|------|-------|------------|-----------|-------|
| Bonded IOB                      | 74   | 0     | 0          | 210       | 35.24 |
| Bonded IPADs                    | 0    | 0     | 0          | 2         | 0.00  |
| PHY_CONTROL                     | 0    | 0     | 0          | 6         | 0.00  |
| PHASER_REF                      | 0    | 0     | 0          | 6         | 0.00  |
| OUT_FIFO                        | 0    | 0     | 0          | 24        | 0.00  |
| IN_FIFO                         | 0    | 0     | 0          | 24        | 0.00  |
| IDELAYCTRL                      | 0    | 0     | 0          | 6         | 0.00  |
| IBUFDS                          | 0    | 0     | 0          | 202       | 0.00  |
| PHASER_OUT/PHASER_OUT_PHY       | 0    | 0     | 0          | 24        | 0.00  |
| PHASER_IN/PHASER_IN_PHY         | 0    | 0     | 0          | 24        | 0.00  |
| IDELAYE2/IDELAYE2_FINEDELAY     | 0    | 0     | 0          | 300       | 0.00  |
| ILOGIC                          | 0    | 0     | 0          | 210       | 0.00  |
| OLOGIC                          | 0    | 0     | 0          | 210       | 0.00  |

##### Clocking

| Site Type   | Used | Fixed | Prohibited | Available | Util% |
|-------------|------|-------|------------|-----------|-------|
| BUFGCTRL    | 1    | 0     | 0          | 32        | 3.13  |
| BUFIO       | 0    | 0     | 0          | 24        | 0.00  |
| MMCME2_ADV  | 0    | 0     | 0          | 6         | 0.00  |
| PLLE2_ADV   | 0    | 0     | 0          | 6         | 0.00  |
| BUFMRCE     | 0    | 0     | 0          | 12        | 0.00  |
| BUFHCE      | 0    | 0     | 0          | 96        | 0.00  |
| BUFR        | 0    | 0     | 0          | 24        | 0.00  |

##### Specific Feature

| Site Type   | Used | Fixed | Prohibited | Available | Util% |
|-------------|------|-------|------------|-----------|-------|
| BSCANE2     | 0    | 0     | 0          | 4         | 0.00  |
| CAPTUREE2   | 0    | 0     | 0          | 1         | 0.00  |
| DNA_PORT    | 0    | 0     | 0          | 1         | 0.00  |
| EFUSE_USR   | 0    | 0     | 0          | 1         | 0.00  |
| FRAME_ECCE2 | 0    | 0     | 0          | 1         | 0.00  |
| ICAPE2      | 0    | 0     | 0          | 2         | 0.00  |
| PCIE_2_1    | 0    | 0     | 0          | 1         | 0.00  |
| STARTUPE2   | 0    | 0     | 0          | 1         | 0.00  |
| XADC        | 0    | 0     | 0          | 1         | 0.00  |

##### Primitivas

| Ref Name | Used  | Functional Category |
|----------|-------|---------------------|
| FDCE     | 14370 | Flop & Latch        |
| LUT4     | 8404  | LUT                 |
| LUT2     | 5643  | LUT                 |
| CARRY4   | 3685  | CarryLogic          |
| FDRE     | 3552  | Flop & Latch        |
| LUT3     | 3281  | LUT                 |
| LUT6     | 2592  | LUT                 |
| LUT5     | 2491  | LUT                 |
| FDSE     | 1008  | Flop & Latch        |
| LUT1     | 402   | LUT                 |
| FDPE     | 320   | Flop & Latch        |
| DSP48E1  | 240   | Block Arithmetic    |
| MUXF7    | 80    | MuxFx               |
| IBUF     | 46    | IO                  |
| MUXF8    | 32    | MuxFx               |
| OBUF     | 28    | IO                  |
| BUFG     | 1     | Clock               |
