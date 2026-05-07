/* ============================================================
   ENCLOSURE v5
   83 × 141 × 47mm total  (base 45mm + tampa plana 2mm)
   Parede 2mm  |  Cantos R3mm

   MUDANÇAS v5 (em relação à v4):
   - BASE_H  30 → 45mm (+15mm)
   - Tampa   sem paredes laterais — placa plana 2mm
   - Encaixe rebaixo (rabbet) 1mm × 2mm no topo da base
     substitui o lábio/press-fit anterior
   - USB_Z   fixo no valor original (Z=11.6mm, base=30mm)
             NÃO recentralizado na nova altura
   - Slot MicroSD migra da tampa para a parede traseira da base
   - LIP_GAP=0.15mm (folga placa/rebaixo)

   COMPARTIMENTOS BASE:
     PCB  : Y  12..104 = 102mm de profundidade
     Rib  : Y 104..106 (furo Ø6mm fio da bateria)
     BAT  : Y 109..130 (bateria 18650: 75.6×21×18.2mm)
   ============================================================ */

$fn   = 64;
EPS   = 0.01;

// ── Caixa ────────────────────────────────────────────────────
ENC_W  = 83;
ENC_L  = 141;
WALL   = 2;
C_RAD  = 3;
BASE_H = 45;   // era 30mm — +15mm

// ── Tampa plana ───────────────────────────────────────────────
// Sem paredes laterais; standoffs pendurados para baixo.
// IT = distância do fundo da placa até referência dos componentes
// (inalterado → mantém posições OLED/SCD/MSD)
IT   = 13;

// ── Encaixe rebaixo (rabbet) ──────────────────────────────────
// Topo das paredes da base recebe um degrau de 1mm × 2mm.
// A placa tampa (80.7 × 138.7mm) assenta nesse degrau.
RABB_T  = 1.0;        // profundidade inward do rebaixo (1mm)
RABB_D  = WALL;       // altura do rebaixo = espessura da placa (2mm)
LIP_GAP = 0.15;       // folga lateral placa/degrau

LID_OFFSET = RABB_T + LIP_GAP;            // = 1.15mm
LID_W      = ENC_W - 2*LID_OFFSET;        // = 80.70mm
LID_L      = ENC_L - 2*LID_OFFSET;        // = 138.70mm
LID_R      = max(0.5, C_RAD - LID_OFFSET);// = 1.85mm

// ── Parafusos M3 ─────────────────────────────────────────────
BOSS_D   = 6;
BOSS_M   = 3;     // boss integrado ao canto (centro em 3,3)
PILOT_D  = 2.5;   // furo piloto auto-roscante no boss
SCREW_CL = 3.4;   // clearance M3

// ── PCB principal ─────────────────────────────────────────────
PCB_W   = 70;
PCB_L   = 90;
HOLE_DW = 66;
HOLE_DL = 85;
POST_OD = 6;
STAND_H = 3;
PCB_X0  = WALL + (ENC_W - 2*WALL - PCB_W) / 2;  // = 6.5mm
PCB_Y0  = WALL + 10;                              // = 12mm

// ── Parede divisória + furo fio bateria ──────────────────────
WIRE_RIB_Y = PCB_Y0 + PCB_L + 2;  // = 104mm
WIRE_RIB_T = 2.0;
WIRE_D     = 6.0;
WIRE_X     = ENC_W / 2;
WIRE_Z     = WALL + 18.2 / 2;     // centro vertical da bateria

// ── Bateria 18650 ─────────────────────────────────────────────
BAT_L    = 75.6;
BAT_W    = 21.0;
BAT_H    = 18.2;
BAT_RAIL = 1.5;
BAT_X0   = WALL + (ENC_W - 2*WALL - BAT_L) / 2;
BAT_Y0   = WIRE_RIB_Y + WIRE_RIB_T + 3;  // = 109mm

// ── Mini USB (Z FIXO — posição original com BASE_H=30mm) ─────
USB_W      = 7.39;
USB_H      = 2.73;
USB_MARGIN = 2.0;
USB_HW     = USB_W + 2*USB_MARGIN;
USB_HH     = USB_H + 2*USB_MARGIN;
USB_CH     = 1.2;
USB1_Y     = PCB_Y0 + (38.2 + (PCB_L - 43.2)) / 2; // = 54.5mm
USB2_Y     = PCB_Y0 + (74.0 + (PCB_L - 11.0)) / 2; // = 88.5mm
USB_Z      = (30 - USB_HH) / 2 + 4 +3.5 + 1.5;  // +4mm solicitado → ~15.6mm

// ── OLED (posições do v3_1) ───────────────────────────────────
OLED_PCB_W   = 27.2;
OLED_PCB_L   = 28.3;
OLED_HOLE_DW = 23.89;
OLED_HOLE_DL = 25;
OLED_WIN_W   = 24.7;
OLED_WIN_L   = 15.55;
OLED_STAND   = 1.5;
OLED_POST_D  = 5.0;
OLED_SCREW   = 1.8;
OLED_CX      = ENC_W / 2;
OLED_CY      = WALL + 4 + OLED_PCB_L / 2;

// ── SCD41 (posições do v3_1) ──────────────────────────────────
SCD_PCB_W    = 23.0;
SCD_PCB_L    = 21.8;
SCD_HOLE_DW  = 18.7;
SCD_HOLE_DL  = 17.6;
SCD_SENS_W   = 8.0;
SCD_SENS_L   = 8.0;
SCD_SENS_OFF = 5.4;
SCD_STAND    = 6.5;
SCD_POST_D   = 5.0;
SCD_SCREW    = 1.8;
SCD_CX       = ENC_W / 2;
SCD_Y0       = WALL + 4 + OLED_PCB_L + 5;
SCD_CY       = SCD_Y0 + SCD_PCB_L / 2;
SCD_SENS_CX  = SCD_CX;
SCD_SENS_CY  = SCD_Y0 + SCD_SENS_OFF + SCD_SENS_L / 2;

// ── MicroSD ───────────────────────────────────────────────────
MSD_PCB_W    = 24.2;
MSD_PCB_L    = 41.9;
MSD_HOLE_DW  = 20.45;
MSD_HOLE_DL  = 36.15;
MSD_PCB_H    = 1.59;
MSD_TOT_H    = 3.56;
MSD_CARD_W   = 18.0;
MSD_CARD_H   = 3.6;
MSD_STAND    = 2.0;
MSD_POST_D   = 4.0;
MSD_SCREW    = 1.8;
MSD_CX       = ENC_W / 2;
MSD_Y1       = ENC_L - WALL;
MSD_Y0       = MSD_Y1 - MSD_PCB_L;
MSD_CY       = MSD_Y0 + MSD_PCB_L / 2;

// Posição Z do slot do cartão — referenciada à BASE (Z absoluto)
// Placa tampa fundo: Z = BASE_H - WALL = 43mm
// PCB MSD topo:      Z = 43 - MSD_STAND = 41mm
// PCB MSD fundo:     Z = 41 - MSD_PCB_H = 39.41mm
// Cartão fundo:      Z = 39.41 - (MSD_TOT_H - MSD_PCB_H) = 37.44mm
MSD_PCB_TOP_BASE  = BASE_H - WALL - MSD_STAND;
MSD_PCB_BOT_BASE  = MSD_PCB_TOP_BASE - MSD_PCB_H;
MSD_CARD_BOT_BASE = MSD_PCB_BOT_BASE - (MSD_TOT_H - MSD_PCB_H);
MSD_CARD_CZ_BASE  = (MSD_PCB_BOT_BASE + MSD_CARD_BOT_BASE) / 2;
MSD_SLOT_M        = 0.5;   // margem extra no slot do cartão

// ════════════════════════════════════════════════════════════
// UTILITÁRIO
// ════════════════════════════════════════════════════════════
module rbox(w, l, h, r) {
    R = (r == undef) ? C_RAD : r;
    linear_extrude(h)
        hull()
            for (xi = [R, w-R], yi = [R, l-R])
                translate([xi, yi]) circle(r = R);
}

// ════════════════════════════════════════════════════════════
// BASE (45mm)
//
// Topo das paredes tem rebaixo de 1mm×2mm para receber a tampa.
// Boss de canto vai até BASE_H; exempt do rebaixo para manter
// acesso ao parafuso M3.
// USB fixo em Z=11.6mm (posição original).
// Slot MicroSD na parede traseira (Y=ENC_L).
// ════════════════════════════════════════════════════════════
module base() {

    pcb_cx = PCB_X0 + PCB_W/2;
    pcb_cy = PCB_Y0 + PCB_L/2;
    EE = 0.5;   // embute sólidos EE mm no fundo
    EX = 0.15;  // margem de exemption

    difference() {

        // ═══════════════════════════════════════
        // SÓLIDOS
        // ═══════════════════════════════════════
        union() {
            // Casco externo (45mm)
            rbox(ENC_W, ENC_L, BASE_H);

            // Boss de canto — topo alinhado com o piso do rebaixo (BASE_H-RABB_D=43mm)
            for (xi=[BOSS_M, ENC_W-BOSS_M],
                 yi=[BOSS_M, ENC_L-BOSS_M])
                translate([xi, yi, WALL-EE])
                    cylinder(d=BOSS_D, h=BASE_H-RABB_D-WALL+EE);

            // Standoffs PCB (M3)
            for (dx=[-HOLE_DW/2, HOLE_DW/2],
                 dy=[-HOLE_DL/2, HOLE_DL/2])
                translate([pcb_cx+dx, pcb_cy+dy, WALL-EE])
                    cylinder(d=POST_OD, h=STAND_H+EE);

            // Rail traseiro bateria
            translate([WALL, BAT_Y0+BAT_W, WALL-EE])
                cube([ENC_W-2*WALL, BAT_RAIL, BAT_H+EE]);

            // Parede divisória PCB/bateria
            translate([WALL-EE, WIRE_RIB_Y, WALL-EE])
                cube([ENC_W-2*WALL+2*EE, WIRE_RIB_T, BAT_H+EE]);
        }

        // ═══════════════════════════════════════
        // CORTES
        // ═══════════════════════════════════════
        union() {

            // ── Cavidade principal (c/ exemptions) ───────
            difference() {
                translate([WALL, WALL, WALL])
                    rbox(ENC_W-2*WALL, ENC_L-2*WALL,
                         BASE_H-WALL, C_RAD-WALL);

                // Exempt bosses
                for (xi=[BOSS_M, ENC_W-BOSS_M],
                     yi=[BOSS_M, ENC_L-BOSS_M])
                    translate([xi, yi, WALL-EE-EPS])
                        cylinder(d=BOSS_D+2*EX,
                                 h=BASE_H-RABB_D-WALL+EE+2*EPS);

                // Exempt standoffs PCB
                for (dx=[-HOLE_DW/2, HOLE_DW/2],
                     dy=[-HOLE_DL/2, HOLE_DL/2])
                    translate([pcb_cx+dx, pcb_cy+dy, WALL-EE-EPS])
                        cylinder(d=POST_OD+2*EX,
                                 h=STAND_H+EE+2*EPS);

                // Exempt rail bateria
                translate([WALL-EX, BAT_Y0+BAT_W-EX, WALL-EE-EPS])
                    cube([ENC_W-2*WALL+2*EX,
                          BAT_RAIL+EX, BAT_H+EE+2*EPS]);

                // Exempt rib divisória
                translate([WALL-EE-EX, WIRE_RIB_Y-EX, WALL-EE-EPS])
                    cube([ENC_W-2*WALL+2*EE+2*EX,
                          WIRE_RIB_T+2*EX, BAT_H+EE+2*EPS]);
            }

            // ── Rebaixo (rabbet) para encaixe da tampa ────
            // 1mm inward × 2mm deep — bosses já terminam em Z=43mm
            // (BASE_H-RABB_D), não precisam de exemption aqui
            translate([RABB_T, RABB_T, BASE_H-RABB_D-EPS])
                rbox(ENC_W-2*RABB_T, ENC_L-2*RABB_T,
                     RABB_D+2*EPS, C_RAD-RABB_T);

            // ── Furos boss M3 (piloto do topo ao fundo) ──
            for (xi=[BOSS_M, ENC_W-BOSS_M],
                 yi=[BOSS_M, ENC_L-BOSS_M])
                translate([xi, yi, WALL+EPS])
                    cylinder(d=PILOT_D, h=BASE_H-RABB_D-WALL-EPS);

            // ── Furos standoffs PCB (piloto + bocal) ──────
            for (dx=[-HOLE_DW/2, HOLE_DW/2],
                 dy=[-HOLE_DL/2, HOLE_DL/2]) {
                translate([pcb_cx+dx, pcb_cy+dy, WALL+EPS])
                    cylinder(d=PILOT_D, h=STAND_H-EPS);
                translate([pcb_cx+dx, pcb_cy+dy, WALL+STAND_H-EPS])
                    cylinder(d=SCREW_CL, h=1.0+2*EPS);
            }

            // ── Furo fio bateria na rib ───────────────────
            translate([WIRE_X, WIRE_RIB_Y-EPS, WIRE_Z])
                rotate([-90,0,0])
                    cylinder(d=WIRE_D, h=WIRE_RIB_T+2*EPS);
            translate([WIRE_X, WIRE_RIB_Y, WIRE_Z])
                rotate([-90,0,0])
                    cylinder(d1=WIRE_D, d2=WIRE_D+2, h=0.8);
            translate([WIRE_X, WIRE_RIB_Y+WIRE_RIB_T, WIRE_Z])
                rotate([90,0,0])
                    cylinder(d1=WIRE_D, d2=WIRE_D+2, h=0.8);

            // ── Mini USB 1 (parede direita X=ENC_W) ───────
            translate([ENC_W-WALL-EPS,
                       USB1_Y-USB_HW/2, USB_Z])
                cube([WALL+2*EPS, USB_HW, USB_HH]);
            hull() {
                translate([ENC_W-WALL,
                           USB1_Y-USB_HW/2, USB_Z])
                    cube([0.5, USB_HW, USB_HH]);
                translate([ENC_W-0.5,
                           USB1_Y-USB_HW/2-USB_CH,
                           USB_Z-USB_CH])
                    cube([0.5, USB_HW+2*USB_CH,
                          USB_HH+2*USB_CH]);
            }

            // ── Mini USB 2 ────────────────────────────────
            translate([ENC_W-WALL-EPS,
                       USB2_Y-USB_HW/2, USB_Z])
                cube([WALL+2*EPS, USB_HW, USB_HH]);
            hull() {
                translate([ENC_W-WALL,
                           USB2_Y-USB_HW/2, USB_Z])
                    cube([0.5, USB_HW, USB_HH]);
                translate([ENC_W-0.5,
                           USB2_Y-USB_HW/2-USB_CH,
                           USB_Z-USB_CH])
                    cube([0.5, USB_HW+2*USB_CH,
                          USB_HH+2*USB_CH]);
            }

            // ── Slot MicroSD — parede traseira (Y=ENC_L) ──
            // Z: 36.94mm a 41.54mm  |  X: 32.0..51.0mm
            translate([MSD_CX - MSD_CARD_W/2 - MSD_SLOT_M,
                       ENC_L - WALL - EPS,
                       MSD_CARD_BOT_BASE - MSD_SLOT_M])
                cube([MSD_CARD_W + 2*MSD_SLOT_M,
                      WALL + 2*EPS,
                      MSD_CARD_H + 2*MSD_SLOT_M]);
            // Chanfro de entrada MSD
            hull() {
                translate([MSD_CX - MSD_CARD_W/2 - MSD_SLOT_M,
                           ENC_L - WALL,
                           MSD_CARD_BOT_BASE - MSD_SLOT_M])
                    cube([MSD_CARD_W + 2*MSD_SLOT_M,
                          0.5, MSD_CARD_H + 2*MSD_SLOT_M]);
                translate([MSD_CX - MSD_CARD_W/2 - MSD_SLOT_M - 0.8,
                           ENC_L - 0.5,
                           MSD_CARD_BOT_BASE - MSD_SLOT_M - 0.5])
                    cube([MSD_CARD_W + 2*MSD_SLOT_M + 1.6,
                          0.5,
                          MSD_CARD_H + 2*MSD_SLOT_M + 1.0]);
            }
        }
    }
}

// ════════════════════════════════════════════════════════════
// TAMPA — placa plana WALL=2mm
//
// Coordenadas locais da tampa:
//   Z=0   = face inferior da placa (standoffs pendurados em -Z)
//   Z=WALL= face superior (visível, furos parafusos)
//
// Na montagem, tampa é posicionada em:
//   translate([LID_OFFSET, LID_OFFSET, BASE_H-RABB_D])
//
// Parafusos: M3 pan-head ×20mm pelo topo → boss na base
// ════════════════════════════════════════════════════════════
module lid() {

    // Posição dos bosses no sistema de coords da placa
    BX = [BOSS_M - LID_OFFSET, ENC_W - BOSS_M - LID_OFFSET];
    BY = [BOSS_M - LID_OFFSET, ENC_L - BOSS_M - LID_OFFSET];

    // Componentes no sistema de coords da placa (offset aplicado)
    ocx   = OLED_CX     - LID_OFFSET;
    ocy   = OLED_CY     - LID_OFFSET;
    scx   = SCD_CX      - LID_OFFSET;
    scy   = SCD_CY      - LID_OFFSET;
    scx_s = SCD_SENS_CX - LID_OFFSET;
    scy_s = SCD_SENS_CY - LID_OFFSET;
    mcx   = MSD_CX      - LID_OFFSET;
    mcy   = MSD_CY      - LID_OFFSET;

    union() {

        // ── 1. PLACA PLANA + FUROS ───────────────────────
        difference() {
            rbox(LID_W, LID_L, WALL, LID_R);

            // Furos parafuso M3 (clearance passante)
            for (xi=BX, yi=BY)
                translate([xi, yi, -EPS])
                    cylinder(d=SCREW_CL, h=WALL+2*EPS);

            // Janela OLED (passante pela placa)
            translate([ocx-OLED_WIN_W/2,
                       ocy-OLED_WIN_L/2, -EPS])
                cube([OLED_WIN_W, OLED_WIN_L, WALL+2*EPS]);
            // Chanfro visual OLED (lado inferior)
            hull() {
                translate([ocx-OLED_WIN_W/2-0.8,
                           ocy-OLED_WIN_L/2-0.8, -EPS])
                    cube([OLED_WIN_W+1.6, OLED_WIN_L+1.6, 0.1]);
                translate([ocx-OLED_WIN_W/2,
                           ocy-OLED_WIN_L/2, 0.1-EPS])
                    cube([OLED_WIN_W, OLED_WIN_L, 0.5]);
            }

            // Grade ventilação SCD41 (3×3 furos Ø2mm)
            for (xi=[-1:1:1], yi=[-1:1:1])
                translate([scx_s + xi*(SCD_SENS_W/2),
                           scy_s + yi*(SCD_SENS_L/2), -EPS])
                    cylinder(d=2, h=WALL+2*EPS);
        }

        // ── 2. STANDOFFS OLED — removidos (placa sem parafusos)

        // ── 3. STANDOFFS SCD41 ───────────────────────────
        difference() {
            for (dx=[-SCD_HOLE_DW/2, SCD_HOLE_DW/2],
                 dy=[-SCD_HOLE_DL/2, SCD_HOLE_DL/2])
                translate([scx+dx, scy+dy, -SCD_STAND])
                    cylinder(d=SCD_POST_D, h=SCD_STAND+1);
            for (dx=[-SCD_HOLE_DW/2, SCD_HOLE_DW/2],
                 dy=[-SCD_HOLE_DL/2, SCD_HOLE_DL/2])
                translate([scx+dx, scy+dy, -SCD_STAND-EPS])
                    cylinder(d=SCD_SCREW, h=SCD_STAND);
        }

        // ── 4. STANDOFFS MICROSD ─────────────────────────
        difference() {
            for (dx=[-MSD_HOLE_DW/2, MSD_HOLE_DW/2],
                 dy=[-MSD_HOLE_DL/2, MSD_HOLE_DL/2])
                translate([mcx+dx, mcy+dy, -MSD_STAND])
                    cylinder(d=MSD_POST_D, h=MSD_STAND+1);
            for (dx=[-MSD_HOLE_DW/2, MSD_HOLE_DW/2],
                 dy=[-MSD_HOLE_DL/2, MSD_HOLE_DL/2])
                translate([mcx+dx, mcy+dy, -MSD_STAND-EPS])
                    cylinder(d=MSD_SCREW, h=MSD_STAND);
        }
    }
}

// ════════════════════════════════════════════════════════════
// CENA — visualização explodida
// ════════════════════════════════════════════════════════════
LID_EXPL = 15;  // espaço de explosão entre base e tampa
LID_Z    = BASE_H - RABB_D + LID_EXPL;  // Z da face inferior da tampa

color("SteelBlue",      0.92) base();

color("CornflowerBlue", 0.55)
    translate([LID_OFFSET, LID_OFFSET, LID_Z])
        lid();

color("#22BB55", 0.45)
    translate([PCB_X0, PCB_Y0, WALL+STAND_H])
        cube([PCB_W, PCB_L, 1.6]);

color("#FF8800", 0.45)
    translate([BAT_X0, BAT_Y0, WALL])
        cube([BAT_L, BAT_W, BAT_H]);

color("Silver", 0.80) {
    translate([ENC_W-2, USB1_Y-USB_W/2, USB_Z+(USB_HH-USB_H)/2])
        cube([3, USB_W, USB_H]);
    translate([ENC_W-2, USB2_Y-USB_W/2, USB_Z+(USB_HH-USB_H)/2])
        cube([3, USB_W, USB_H]);
}

// Componentes na tampa (posição montada + explosão)
color("#1166DD", 0.55)
    translate([OLED_CX-OLED_PCB_W/2, OLED_CY-OLED_PCB_L/2,
               LID_Z-OLED_STAND-1.6])
        cube([OLED_PCB_W, OLED_PCB_L, 1.6]);

color("#CC2222", 0.55)
    translate([SCD_CX-SCD_PCB_W/2, SCD_Y0,
               LID_Z-SCD_STAND-8])
        cube([SCD_PCB_W, SCD_PCB_L, 8]);

color("#DDAA00", 0.55)
    translate([MSD_CX-MSD_PCB_W/2, MSD_Y0,
               LID_Z-MSD_STAND-MSD_TOT_H])
        cube([MSD_PCB_W, MSD_PCB_L, MSD_TOT_H]);

/* ─────────────────────────────────────────────────────
   IMPRESSÃO 3D — v5

   BASE:
     use <enclosure_v5.scad>
     base();

   TAMPA (standoffs para cima no build plate):
     use <enclosure_v5.scad>
     rotate([180,0,0]) translate([0,-LID_L,-WALL]) lid();

   ENCAIXE (rebaixo):
     Tampa encaixa no degrau de 1mm das paredes.
     LIP_GAP=0.15mm → ajuste se necessário:
       mais folga : 0.20mm  |  mais firme : 0.10mm

   Parafusos:
     Tampa/base  : 4× M3×20mm pan-head (pelo topo da tampa)
     PCB         : 4× M3×6mm auto-roscante
     Placas OLED/SCD/MSD : M2×6mm auto-roscante (4 cada)

   Slot MicroSD : na parede traseira da base (Y=141mm)
                  Z ≈ 37.0..41.5mm
   ───────────────────────────────────────────────────── */
