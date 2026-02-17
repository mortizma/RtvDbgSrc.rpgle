/*                            |||||||                                */
/*                           ( o   o )                               */
/* ----------------------oOO----(_)----OOo-------------------------- */
/* Command ....: RTVDBGSRC                                           */
/* Description : Retrieve Program's Source from Program's Debug Data */
/* CPP program : RTVDBGSRCC                                          */
/* Author .....: ortizmartin.miguel@gmail.com                        */
/* Date .......:   /01/2026                                          */
/* ----------------------------------------------------------------- */
             CMD        PROMPT('Retrieve Program Source')

             PARM       KWD(OBJECT) TYPE(QUAL1) MIN(1) +
                          PROMPT('Object')
             PARM       KWD(OBJTYPE) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*PGM) VALUES(*PGM *SRVPGM) +
                          PROMPT('Object type')

 QUAL1:      QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL) (*CURLIB)) +
                          PROMPT('Library')
