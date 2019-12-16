// SNES SPC700 CPU Test ADC (Add With Carry) demo (SPC Code) by krom (Peter Lemon):
arch snes.smp
output "SPC700ADC.spc", create

macro seek(variable offset) { // Set SPC700 Memory Map
  origin (offset - SPCRAM)
  base offset
}

include "LIB/SNES_SPC700.INC" // Include SPC700 Definitions & Macros

seek(SPCRAM); Start:
  SPC_INIT() // Run SPC700 Initialisation Routine

  WDSP(DSP_DIR,sampleDIR >> 8) // Sample Directory Offset

  WDSP(DSP_KOFF,$00) // Reset Key Off Flags
  WDSP(DSP_MVOLL,127) // Master Volume Left
  WDSP(DSP_MVOLR,127) // Master Volume Right

  SPCRAMClear($8800,$78) // Clear Echo Buffer RAM
  WDSP(DSP_ESA,$88)  // Echo Source Address
  WDSP(DSP_EDL,5)    // Echo Delay
  WDSP(DSP_EON,%00000011) // Echo On Flags
  WDSP(DSP_FLG,0)    // Enable Echo Buffer Writes
  WDSP(DSP_EFB,80)   // Echo Feedback
  WDSP(DSP_FIR0,127) // Echo FIR Filter Coefficient 0
  WDSP(DSP_FIR1,0)   // Echo FIR Filter Coefficient 1
  WDSP(DSP_FIR2,0)   // Echo FIR Filter Coefficient 2
  WDSP(DSP_FIR3,0)   // Echo FIR Filter Coefficient 3
  WDSP(DSP_FIR4,0)   // Echo FIR Filter Coefficient 4
  WDSP(DSP_FIR5,0)   // Echo FIR Filter Coefficient 5
  WDSP(DSP_FIR6,0)   // Echo FIR Filter Coefficient 6
  WDSP(DSP_FIR7,0)   // Echo FIR Filter Coefficient 7
  WDSP(DSP_EVOLL,25) // Echo Volume Left
  WDSP(DSP_EVOLR,25) // Echo Volume Right

  WDSP(DSP_V0VOLL,127)        // Voice 0: Volume Left
  WDSP(DSP_V0VOLR,127)        // Voice 0: Volume Right
  WDSP(DSP_V0PITCHL,$00)      // Voice 0: Pitch (Lower Byte)
  WDSP(DSP_V0PITCHH,$10)      // Voice 0: Pitch (Upper Byte)
  WDSP(DSP_V0SRCN,0)          // Voice 0: Sample
  WDSP(DSP_V0ADSR1,%11111010) // Voice 0: ADSR1
  WDSP(DSP_V0ADSR2,%11100000) // Voice 0: ADSR2
  WDSP(DSP_V0GAIN,127)        // Voice 0: Gain

  WDSP(DSP_V1VOLL,127)        // Voice 1: Volume Left
  WDSP(DSP_V1VOLR,127)        // Voice 1: Volume Right
  WDSP(DSP_V1PITCHL,$00)      // Voice 1: Pitch (Lower Byte)
  WDSP(DSP_V1PITCHH,$08)      // Voice 1: Pitch (Upper Byte)
  WDSP(DSP_V1SRCN,0)          // Voice 1: Sample
  WDSP(DSP_V1ADSR1,%11111010) // Voice 1: ADSR1
  WDSP(DSP_V1ADSR2,%11100000) // Voice 1: ADSR2
  WDSP(DSP_V1GAIN,127)        // Voice 1: Gain

SongStart:

  /////////////////////////////////////////////////////////////////
  // Setup Flags
  clc // Clear Carry Flag

  // Run Test
  lda #$7F // A = $7F
  adc #$81 // A += $81
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b $E1 // Store Result Data
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$00 // Result Check
  beq Pass1
  Fail1:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$81 // Store Handshake Between CPU<->APU
  Fail1Loop:
    bra Fail1Loop
  Pass1:
    cpx #$0B // PSW Result Check
    bne Fail1
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$01 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)

  /////////////////////////////////////////////////////////////////
  // Setup Flags
  sec // Set Carry Flag

  // Run Test
  lda #$7F // A = $7F
  adc #$7F // A += $7F
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b $E1 // Store Result Data
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$FF // Result Check
  beq Pass2
  Fail2:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$82 // Store Handshake Between CPU<->APU
  Fail2Loop:
    bra Fail2Loop
  Pass2:
    cpx #$C8 // PSW Result Check
    bne Fail2
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$02 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)


  /////////////////////////////////////////////////////////////////
  // Setup Flags
  clc // Clear Carry Flag

  // Run Test
  str $E1=#$81 // Store DP Data
  lda #$7F // A = $7F
  adc.w $00E1 // A += $81
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$00 // Result Check
  beq Pass3
  Fail3:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$83 // Store Handshake Between CPU<->APU
  Fail3Loop:
    bra Fail3Loop
  Pass3:
    cpx #$0B // PSW Result Check
    bne Fail3
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$03 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)

  /////////////////////////////////////////////////////////////////
  // Setup Flags
  sec // Set Carry Flag

  // Run Test
  str $E1=#$7F // Store DP Data
  lda #$7F // A = $7F
  adc.w $00E1 // A += $7F
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$FF // Result Check
  beq Pass4
  Fail4:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$84 // Store Handshake Between CPU<->APU
  Fail4Loop:
    bra Fail4Loop
  Pass4:
    cpx #$C8 // PSW Result Check
    bne Fail4
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$04 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)


  /////////////////////////////////////////////////////////////////
  // Setup Flags
  clc // Clear Carry Flag

  // Run Test
  str $E1=#$81 // Store DP Data
  lda #$7F // A = $7F
  adc.b $E1 // A += $81
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$00 // Result Check
  beq Pass5
  Fail5:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$85 // Store Handshake Between CPU<->APU
  Fail5Loop:
    bra Fail5Loop
  Pass5:
    cpx #$0B // PSW Result Check
    bne Fail5
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$05 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)

  /////////////////////////////////////////////////////////////////
  // Setup Flags
  sec // Set Carry Flag

  // Run Test
  str $E1=#$7F // Store DP Data
  lda #$7F // A = $7F
  adc.b $E1 // A += $7F
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$FF // Result Check
  beq Pass6
  Fail6:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$86 // Store Handshake Between CPU<->APU
  Fail6Loop:
    bra Fail6Loop
  Pass6:
    cpx #$C8 // PSW Result Check
    bne Fail6
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$06 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)


  /////////////////////////////////////////////////////////////////
  // Setup Flags
  clc // Clear Carry Flag

  // Run Test
  str $E1=#$81 // Store DP Data
  lda #$7F // A = $7F
  ldx #$00 // X = 0
  adc.w $00E1,x // A += $81
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$00 // Result Check
  beq Pass7
  Fail7:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$87 // Store Handshake Between CPU<->APU
  Fail7Loop:
    bra Fail7Loop
  Pass7:
    cpx #$0B // PSW Result Check
    bne Fail7
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$07 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)

  /////////////////////////////////////////////////////////////////
  // Setup Flags
  sec // Set Carry Flag

  // Run Test
  str $E1=#$7F // Store DP Data
  lda #$7F // A = $7F
  ldx #$00 // X = 0
  adc.w $00E1,x // A += $7F
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$FF // Result Check
  beq Pass8
  Fail8:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$88 // Store Handshake Between CPU<->APU
  Fail8Loop:
    bra Fail8Loop
  Pass8:
    cpx #$C8 // PSW Result Check
    bne Fail8
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$08 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)


  /////////////////////////////////////////////////////////////////
  // Setup Flags
  clc // Clear Carry Flag

  // Run Test
  str $E1=#$81 // Store DP Data
  lda #$7F // A = $7F
  ldy #$00 // Y = 0
  adc $00E1,y // A += $81
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$00 // Result Check
  beq Pass9
  Fail9:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$89 // Store Handshake Between CPU<->APU
  Fail9Loop:
    bra Fail9Loop
  Pass9:
    cpx #$0B // PSW Result Check
    bne Fail9
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$09 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)

  /////////////////////////////////////////////////////////////////
  // Setup Flags
  sec // Set Carry Flag

  // Run Test
  str $E1=#$7F // Store DP Data
  lda #$7F // A = $7F
  ldy #$00 // Y = 0
  adc $00E1,y // A += $7F
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$FF // Result Check
  beq Pass10
  Fail10:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$8A // Store Handshake Between CPU<->APU
  Fail10Loop:
    bra Fail10Loop
  Pass10:
    cpx #$C8 // PSW Result Check
    bne Fail10
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$0A // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)


  /////////////////////////////////////////////////////////////////
  // Setup Flags
  clc // Clear Carry Flag

  // Run Test
  str $E1=#$81 // Store DP Data
  lda #$7F // A = $7F
  ldx #$00 // X = 0
  adc.b $E1,x // A += $81
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$00 // Result Check
  beq Pass11
  Fail11:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$8B // Store Handshake Between CPU<->APU
  Fail11Loop:
    bra Fail11Loop
  Pass11:
    cpx #$0B // PSW Result Check
    bne Fail11
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$0B // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)

  /////////////////////////////////////////////////////////////////
  // Setup Flags
  sec // Set Carry Flag

  // Run Test
  str $E1=#$7F // Store DP Data
  lda #$7F // A = $7F
  ldx #$00 // X = 0
  adc.b $E1,x // A += $7F
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$FF // Result Check
  beq Pass12
  Fail12:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$8C // Store Handshake Between CPU<->APU
  Fail12Loop:
    bra Fail12Loop
  Pass12:
    cpx #$C8 // PSW Result Check
    bne Fail12
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$0C // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)


  /////////////////////////////////////////////////////////////////
  // Setup Flags
  clc // Clear Carry Flag

  // Run Test
  str $E1=#$81 // Store DP Data
  str $E2=#$E1 // Store Indirect Data
  str $E3=#$00 // Store Indirect Data
  lda #$7F // A = $7F
  ldx #$00 // X = 0
  adc ($E2,x) // A += $81
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$00 // Result Check
  beq Pass13
  Fail13:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$8D // Store Handshake Between CPU<->APU
  Fail13Loop:
    bra Fail13Loop
  Pass13:
    cpx #$0B // PSW Result Check
    bne Fail13
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$0D // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)

  /////////////////////////////////////////////////////////////////
  // Setup Flags
  sec // Set Carry Flag

  // Run Test
  str $E1=#$7F // Store DP Data
  str $E2=#$E1 // Store Indirect Data
  str $E3=#$00 // Store Indirect Data
  lda #$7F // A = $7F
  ldx #$00 // X = 0
  adc ($E2,x) // A += $7F
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$FF // Result Check
  beq Pass14
  Fail14:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$8E // Store Handshake Between CPU<->APU
  Fail14Loop:
    bra Fail14Loop
  Pass14:
    cpx #$C8 // PSW Result Check
    bne Fail14
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$0E // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)


  /////////////////////////////////////////////////////////////////
  // Setup Flags
  clc // Clear Carry Flag

  // Run Test
  str $E1=#$81 // Store DP Data
  str $E2=#$E1 // Store Indirect Data
  str $E3=#$00 // Store Indirect Data
  lda #$7F // A = $7F
  ldy #$00 // Y = 0
  adc ($E2),y // A += $81
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$00 // Result Check
  beq Pass15
  Fail15:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$8F // Store Handshake Between CPU<->APU
  Fail15Loop:
    bra Fail15Loop
  Pass15:
    cpx #$0B // PSW Result Check
    bne Fail15
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$0F // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)

  /////////////////////////////////////////////////////////////////
  // Setup Flags
  sec // Set Carry Flag

  // Run Test
  str $E1=#$7F // Store DP Data
  str $E2=#$E1 // Store Indirect Data
  str $E3=#$00 // Store Indirect Data
  lda #$7F // A = $7F
  ldy #$00 // Y = 0
  adc ($E2),y // A += $7F
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$FF // Result Check
  beq Pass16
  Fail16:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$90 // Store Handshake Between CPU<->APU
  Fail16Loop:
    bra Fail16Loop
  Pass16:
    cpx #$C8 // PSW Result Check
    bne Fail16
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$10 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)


  /////////////////////////////////////////////////////////////////
  // Setup Flags
  clc // Clear Carry Flag

  // Run Test
  str $E1=#$81 // Store Indirect Data
  lda #$7F // A = $7F
  ldx #$E1 // X = Indirect Data
  adc (x) // A += $81
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$00 // Result Check
  beq Pass17
  Fail17:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$91 // Store Handshake Between CPU<->APU
  Fail17Loop:
    bra Fail17Loop
  Pass17:
    cpx #$0B // PSW Result Check
    bne Fail17
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$11 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)

  /////////////////////////////////////////////////////////////////
  // Setup Flags
  sec // Set Carry Flag

  // Run Test
  str $E1=#$7F // Store Indirect Data
  lda #$7F // A = $7F
  ldx #$E1 // X = Indirect Data
  adc (x) // A += $7F
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$FF // Result Check
  beq Pass18
  Fail18:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$92 // Store Handshake Between CPU<->APU
  Fail18Loop:
    bra Fail18Loop
  Pass18:
    cpx #$C8 // PSW Result Check
    bne Fail18
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$12 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)


  /////////////////////////////////////////////////////////////////
  // Setup Flags
  clc // Clear Carry Flag

  // Run Test
  str $E1=#$81 // Store Indirect Data
  str $E2=#$7F // Store Indirect Data
  ldx #$E1 // X = Indirect Data
  ldy #$E2 // Y = Indirect Data
  adc (x)=(y) // (X) += (Y)
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  lda.b $E1 // Load Result
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$00 // Result Check
  beq Pass19
  Fail19:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$93 // Store Handshake Between CPU<->APU
  Fail19Loop:
    bra Fail19Loop
  Pass19:
    cpx #$0B // PSW Result Check
    bne Fail19
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$13 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)

  /////////////////////////////////////////////////////////////////
  // Setup Flags
  sec // Set Carry Flag

  // Run Test
  str $E1=#$7F // Store Indirect Data
  str $E2=#$7F // Store Indirect Data
  ldx #$E1 // X = Indirect Data
  ldy #$E2 // Y = Indirect Data
  adc (x)=(y) // (X) += (Y)
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  lda.b $E1 // Load Result
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$FF // Result Check
  beq Pass20
  Fail20:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$94 // Store Handshake Between CPU<->APU
  Fail20Loop:
    bra Fail20Loop
  Pass20:
    cpx #$C8 // PSW Result Check
    bne Fail20
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$14 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)


  /////////////////////////////////////////////////////////////////
  // Setup Flags
  clc // Clear Carry Flag

  // Run Test
  str $E1=#$81 // Store DP Data
  adc $E1=#$7F // DP += $7F
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  lda.b $E1 // Load Result
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$00 // Result Check
  beq Pass21
  Fail21:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$95 // Store Handshake Between CPU<->APU
  Fail21Loop:
    bra Fail21Loop
  Pass21:
    cpx #$0B // PSW Result Check
    bne Fail21
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$15 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)

  /////////////////////////////////////////////////////////////////
  // Setup Flags
  sec // Set Carry Flag

  // Run Test
  str $E1=#$7F // Store DP Data
  adc $E1=#$7F // DP += $7F
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  lda.b $E1 // Load Result
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$FF // Result Check
  beq Pass22
  Fail22:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$96 // Store Handshake Between CPU<->APU
  Fail22Loop:
    bra Fail22Loop
  Pass22:
    cpx #$C8 // PSW Result Check
    bne Fail22
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$16 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)


  /////////////////////////////////////////////////////////////////
  // Setup Flags
  clc // Clear Carry Flag

  // Run Test
  str $E1=#$81 // Store DP Data
  str $E2=#$7F // Store DP Data
  adc $E1=$E2 // DP += DP
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  lda.b $E1 // Load Result
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$00 // Result Check
  beq Pass23
  Fail23:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$97 // Store Handshake Between CPU<->APU
  Fail23Loop:
    bra Fail23Loop
  Pass23:
    cpx #$0B // PSW Result Check
    bne Fail23
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$17 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)

  /////////////////////////////////////////////////////////////////
  // Setup Flags
  sec // Set Carry Flag

  // Run Test
  str $E1=#$7F // Store DP Data
  str $E2=#$7F // Store DP Data
  adc $E1=$E2 // DP += DP
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  lda.b $E1 // Load Result
  sta.b REG_CPUIO2 // Store Handshake Between CPU<->APU
  cmp #$FF // Result Check
  beq Pass24
  Fail24:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$98 // Store Handshake Between CPU<->APU
  Fail24Loop:
    bra Fail24Loop
  Pass24:
    cpx #$C8 // PSW Result Check
    bne Fail24
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$18 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)


  /////////////////////////////////////////////////////////////////
  // Setup Flags
  clc // Clear Carry Flag

  // Run Test
  ldy #$80 // Y = $80
  lda #$01 // A = $01
  stw $E1  // Store Word Data
  ldy #$7F // Y = $7F
  lda #$FF // A = $FF
  adw $E1 // YA += Word
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  stw REG_CPUIO2 // Store Handshake Between CPU<->APU
  ldx #$00 // X = $00
  stx.b $E1 // Store Word
  stx.b $E2
  cpw $E1 // Result Check
  beq Pass25
  Fail25:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$99 // Store Handshake Between CPU<->APU
  Fail25Loop:
    bra Fail25Loop
  Pass25:
    ldx.b $E0 // Load PSW Result
    cpx #$0B // PSW Result Check
    bne Fail25
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$19 // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)

  /////////////////////////////////////////////////////////////////
  // Setup Flags
  sec // Set Carry Flag

  // Run Test
  ldy #$7F // Y = $7F
  lda #$FF // A = $FF
  stw $E1  // Store Word Data
  ldy #$7F // Y = $7F
  lda #$FF // A = $FF
  adw $E1 // YA += Word
  php // Push Processor Status Register To Stack

  // Check Result & Processor Status Flag Data
  plx // Pull X Register From Stack (X = Processor Status Flag Data)
  stx.b $E0 // Store PSW Result Data
  stx.b REG_CPUIO1 // Store Handshake Between CPU<->APU
  stw REG_CPUIO2 // Store Handshake Between CPU<->APU
  ldx #$FE // X = $FE
  stx.b $E1 // Store Word
  ldx #$FF // X = $FF
  stx.b $E2
  cpw $E1 // Result Check
  beq Pass26
  Fail26:
    WDSP(DSP_KON,%00000010) // Play Voice 1 (FAIL)
    str REG_CPUIO0=#$9A // Store Handshake Between CPU<->APU
  Fail26Loop:
    bra Fail26Loop
  Pass26:
    ldx.b $E0 // Load PSW Result
    cpx #$C8 // PSW Result Check
    bne Fail26
    WDSP(DSP_KON,%00000001) // Play Voice 0 (PASS)
    str REG_CPUIO0=#$1A // Store Handshake Between CPU<->APU

  SPCWaitSHIFTMS(256, 2) // Wait For Shifted MilliSecond Amount (8kHz Timer)


Loop:
  jmp Loop

seek($0A00); sampleDIR:
  dw BRRSample, 0 // BRR Sample Offset, Loop Point

seek($0B00) // Sample Data
  insert BRRSample, "airhorn.brr"