**Free
//                             |||||||                               //
//                            ( o   o )                              //
//  ----------------------oOO----(_)----OOo------------------------  //
//  Program ....: RTVDBGSRCR                                         //
//  Description.: Retrieve program source from Debugging view        //
//  Author .....: ortizmartin.miguel@gmail.com                       //
//  Date .......:   /01/2026                                         //
//  ---------------------------------------------------------------  //
ctl-opt DftActGrp( *No ) ActGrp( 'QTEDBGAG' )
        DatFmt( *iso )   TimFmt( *iso )
        DecEdit( '0.' )  AlwNull( *UsrCtl )
        Option( *noDebugIO : *SrcStmt )  Debug( *yes );

//  ===============================================================  //
//  Declare Files                                                    //
//  ===============================================================  //
dcl-f  RtvDbgSrcD     WorkStn InfDs( dspf ) IndDs( dspInd )
                              sFile( Win01S : rrn01 )
                              sFile( Pnl02S : rrn02 );

//  ===============================================================  //
//  Define data types                                                //
//  ===============================================================  //
dcl-s  TE_Name_t         Char( 10 )    Template;
dcl-s  TE_Format_t       Char(  8 )    Template;
dcl-s  TE_TimeStamp_t    Char( 13 )    Template;
dcl-s  receiverVar_t     Char( 65535 ) Template;

dcl-ds TE_SysFmt_t       Qualified   Template;
         obj             Char( 10 );
         lib             Char( 10 );
end-ds;

dcl-ds TE_TextBuffer_T   Qualified  Template;
         bytesProv       Int ( 10 ) Inz( %size( TE_TextBuffer_T ));
         bytesAvai       Int ( 10 ) Inz( 0 );
         numLines        Int ( 10 );
         lineLength      Int ( 10 );
         //> Text        Char(  * );
end-ds;

dcl-ds VEWL0100_elem     Qualified  Template;
         moduleName      Char( 10 );
         viewType        Char( 10 );
         compilerId      Char( 20 );
         mainIndicator   Char( 10 );
         viewTimestamp   Char( 13 );
         viewDescription Char( 50 );
         *n              Char(  3 );
         viewNumber      Int ( 10 );
         numberOfViews   Int ( 10 );
end-ds;

dcl-ds VEWL0100_t        Qualified  Template;
         bytesProv       Int ( 10 ) Inz( %size( VEWL0100_t ));
         bytesAvai       Int ( 10 );
         numElements     Int ( 10 );
         //> entries     //> Char( * );
         entry01         LikeDs( VEWL0100_elem );
end-ds;

dcl-ds rcvm0100_t        Qualified  Template;
         bytesProv       Int (  10 ) Inz( %size( rcvm0100_t ));
         bytesAvai       Int (  10 );
         msgSevrty       Int (  10 );
         msgId           Char(   7 );
         msgType         Char(   2 );
         msgKey          Char(   4 );
         *n              Char(   7 );
         msgDtaCCSID     Int (  10 );
         msgTxtCCSID     Int (  10 );
         rplDtaLnProv    Int (  10 );
         rplDtaLnAvai    Int (  10 );
         rplDta          Char( 512 );
end-ds;

dcl-ds rtvm0100_t        Qualified  Template;
         bytesRetrn      Int (  10 );
         bytesAvail      Int (  10 );
         lenMsgRetrn     Int (  10 );
         lenMsgAvail     Int (  10 );
         lenMsgHlpRetrn  Int (  10 );
         lenMsgHlpAvail  Int (  10 );
         msgText         Char( 512 );
end-ds;

dcl-ds errCode_t         Qualified  Template;
         bytesProv       Int (  10 ) Inz( %size( errCode_t ));
         bytesAvai       Int (  10 );
         exceptId        Char(   7 );
         *n              Char(   1 );
         exceptData      Char( 256 );
end-ds;

//  ===============================================================  //
//  Declare prototypes for external calls                            //
//  ===============================================================  //
//  Debugger APIs                                                    //
//  ---------------------------------------------------------------  //
//  Debug Session Control APIs                                       //
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  //
//  QteStartSourceDebug - Start Source Debug
dcl-pr StartSourceDebug     ExtProc( 'QteStartSourceDebug' );
          stopHandler       Like( TE_SysFmt_t );
          errorCode         Like( errCode_t );
end-pr;
//  QteEndSourceDebug - End Source Debug
dcl-pr EndSourceDebug       ExtProc( 'QteEndSourceDebug' );
          errorCode         Like( errCode_t );
end-pr;

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  //
//  View Information APIs                                            //
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  //
//  QteRegisterDebugView - registers a view of a module
dcl-pr RegisterDebugView    ExtProc( 'QteRegisterDebugView' );
          viewId            Int ( 10 );
          numberOfLines     Int ( 10 );
          rtnLibrary        Char( 10 );
          viewTimestamp     Char( 13 );
          qualProgramName   Char( 20 )  Const;
          programType       Char( 10 )  Const;
          moduleName        Char( 10 )  Const;
          viewNumber        Int ( 10 )  Const;
          errorCode         Like( errCode_t );
end-pr;
//  QteRetrieveViewText - Retrieves the text of a view.
dcl-pr RetrieveViewText     ExtProc( 'QteRetrieveViewText' );
          receiverVar       Pointer     Value;
          receiverVarLen    Int ( 10 )  Const;
          viewId            Int ( 10 )  Const;
          startLine         Int ( 10 )  Const;
          numberOfLines     Int ( 10 )  Const;
          lineLength        Int ( 10 )  Const;
          errorCode         Like( errCode_t );
end-pr;
//  QteRetrieveModuleViews - Retrieve Module Views
dcl-pr RetrieveModuleViews  ExtProc( 'QteRetrieveModuleViews' );
          receiverVar       Like( receiverVar_t ) Options( *Varsize );
          receiverVarLen    Int ( 10 )  Const;
          formatName        Char(  8 )  Const;
          programName       Char( 20 )  Const;
          programType       Char( 10 )  Const;
          moduleName        Char( 10 )  Const;
          rtnLibName        Char( 10 );
          errorCode         Like( errCode_t );
end-pr;

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  //
//  Message Handling APIs                                            //
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  //
//  QMHRCVPM - Receive Program Message
dcl-pr RcvPgmMsg            ExtPgm( 'QMHRCVPM' );
          msgInfo           Like( rcvm0100_t ) Options( *VarSize );
          msgInfoLen        Int (   10 ) Const;
          formatName        Char(    8 ) Const;
          callStack         Char(   10 ) Const;
          callStkCtr        Int (   10 ) Const;
          msgType           Char(   10 ) Const;
          msgKey            Char(    4 ) Const;
          waitTime          Int (   10 ) Const;
          msgAction         Char(   10 ) Const;
          errorCode         Char( 1024 ) Options( *VarSize );
end-pr;
//  QMHRMVPM - Remove Program Messages
dcl-pr RmvPgmMsg            ExtPgm( 'QMHRMVPM' );
          callStackEntry    Char(  10 ) Const;
          callStackCounter  Int (  10 ) Const;
          messageKey        Char(   4 ) Const;
          messagesToRemove  Char(  10 ) Const;
          errorCode         Char( 512 ) Options( *VarSize );
end-pr;
//  QMHRTVM - Retrieve Message
dcl-pr RetrieveMsg          ExtPgm( 'QMHRTVM' );
          msgInfo           Like( rtvm0100_t ) Options( *VarSize );
          msgInfoLen        Int (  10 ) Const;
          formatName        Char(   8 ) Const;
          msgId             Char(   7 ) Const;
          qualMsgF          Char(  20 ) Const;
          rplData           Char( 512 ) Options( *VarSize ) Const;
          msgInfoLen        Int (  10 ) Const;
          rplValues         Char(  10 ) Options( *VarSize ) Const;
          returnFCC         Char(  10 ) Const;
          errorCode         Char( 514 ) Options( *VarSize ) Const;
end-pr;

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  //
//  Miscellaneuos APIs                                               //
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  //
dcl-pr EndActGrp      ExtProc( 'CEETREC' );
end-pr;
dcl-pr qUsCmdLn       ExtPgm( 'QUSCMDLN' );
end-pr;
dcl-pr ExecCmd        ExtPgm( 'QCMDEXC' );
          cmd         Char  ( 1024 )     Const Options( *VarSize );
          cmdlen      Packed(   15 : 5 ) Const;
end-pr;
dcl-s  sysCmd         VarChar( 1024 );

//  ===============================================================  //
//  Declare Global Variables                                         //
//  ===============================================================  //
dcl-ds sds pSds;
          pgmName     Char( 10 ) Pos(   1 );
          status      Char( 10 ) Pos(  11 );
          jobName     Char( 10 ) Pos( 244 );
          jobUser     Char( 10 ) Pos( 254 );
          jobNbr      Char(  6 ) Pos( 264 );
end-ds;

dcl-ds dspf           Qualified;
          cmdKey      Char( 1 ) Pos( 369 );
          cursor      Int ( 5 ) Pos( 370 );
          rcdLen      Int( 10 ) Pos( 372 );
          sflRcdNbr   Int ( 5 ) Pos( 376 );
          sflRrnTop   Int ( 5 ) Pos( 378 );
          sflTotRcd   Int ( 5 ) Pos( 380 );
end-ds;

dcl-ds dspInd         Qualified;
          // display error(s) in filed(s)
          errOption   Ind   Pos( 31 );
          errCmd      Ind   Pos( 31 );
          errSrcF     Ind   Pos( 31 );
          errSrcL     Ind   Pos( 32 );
          errSrcM     Ind   Pos( 33 );
          errLinOpt   Ind   Pos( 34 );
          // select view [SFL]
          dspCtl01    Ind   Pos( 70 );
          dspSfl01    Ind   Pos( 71 );
          clrSfl01    Ind   Pos( 72 );
          sflEnd01    Ind   Pos( 73 );
          sflNxtChg   Ind   Pos( 75 );
          // show view [SFL]
          dspCtl02    Ind   Pos( 80 );
          dspSfl02    Ind   Pos( 81 );
          clrSfl02    Ind   Pos( 82 );
          sflEnd02    Ind   Pos( 83 );
          // error subfile
          dspSflErr   Ind   Pos( 99 );
end-ds;
dcl-c  F1             Const ( x'31' );
dcl-c  F3             Const ( x'33' );
dcl-c  F5             Const ( x'35' );
dcl-c  F7             Const ( x'37' );
dcl-c  F8             Const ( x'38' );
dcl-c  F12            Const ( x'3C' );
dcl-c  F16            Const ( x'B4' );
dcl-c  F19            Const ( x'B7' );
dcl-c  F20            Const ( x'B8' );
dcl-c  F21            Const ( x'B9' );

dcl-s  rrn01          Packed( 4 );
dcl-s  rrn02          Packed( 4 );

//  ---------------------------------------------------------------  //
//  Global Variables                                                 //
//  ---------------------------------------------------------------  //
//>-ds objToDebugInfo Like( TE_SysFmt_t );
dcl-s  objToDebugType Char( 10 ) DtaAra( 'QTEMP/ZTEOBJTYPE' );
dcl-ds viewText       Qualified;
          modName     Char( 10 );
          viewId      Int ( 10 );
          viewType    Char( 10 );
          viewDesc    Char( 50 );
end-ds;

dcl-s  textBuffer_p   Pointer;
dcl-ds bufferOff      LikeDs( TE_TextBuffer_t ) Based( bufferOff_p );
dcl-s  bufferSize     Int (  10 )  Inz( 10192012 );
dcl-s  lineLength     Int (  10 )  Inz( 140 );
dcl-ds srcText        Qualified    Based( srcText_p );
          seq         Char(   6 );
          dat         Char(   6 );
          dta         Char( 100 );
end-ds;
dcl-ds srcList        Len ( 140 )  Based( srcList_P )
end-ds;

dcl-ds qteErrCode     LikeDs( errCode_t ) Inz( *LikeDs );
dcl-ds mhErrCode      LikeDs( errCode_t ) Inz( *LikeDs );

//  ===============================================================  //
//  main: Entry point for the debugger (session or stop handler)     //
//  ===============================================================  //
dcl-pi *n;
   //> Only 3 arguments expected: called as source debug program
   //> argc           Int   ( 10 );
   reason             Char  ( 10 );
   objToDebug         LikeDs( TE_SysFmt_t )  Options( *NoPass );
   pgmListCount       Int   ( 10 )           Options( *NoPass );
   reason2            Char  ( 10 )           Options( *NoPass );
end-pi;

//  called as program stop handler_____________________________________
//  --> events like breakpoint, step, unmonitored exception, etc.
if  %passed( reason2 );
    //> HandleStop( );

//  called as source debug program_____________________________________
//  --> events STRDBG, DSPMODSRC and ENDDBG.
else;
    HandleSession( );
endIf;

//> *inlr = *on;
return;

//  ===============================================================  //
//  HandleSession: This function is called to handle the session     //
//  ===============================================================  //
dcl-proc  HandleSession;
   dcl-pi *n     end-pi;

   Select reason;
     When-Is '*START';
          CLEAR_Sfl01( );
          StartUpDebugger( );
     When-Is '*DISPLAY';
          WIN01_Ctl( );
     When-Is '*STOP';
          TearDownDebugger( );
          EndActGrp( );
   endSl;
end-proc;

//  ===============================================================  //
//  StartUpDebugger: Initialize the debugger.                        //
//  ===============================================================  //
dcl-proc  StartUpDebugger;
   dcl-pi *n  end-pi;
   dcl-ds stopHandler  LikeDs( TE_SysFmt_t );

   stopHandler.obj = 'RTVDBGSRCR';
   stopHandler.lib = '*LIBL';
   StartSourceDebug( stopHandler : qteErrCode );

   in  objToDebugType;
   callp(e) AddProgram( );
end-proc;

//  ===============================================================  //
//  AddProgram: Add a program to debug mode.                         //
//  ===============================================================  //
dcl-proc  AddProgram;
   dcl-pi *n  end-pi;
   dcl-ds pgmDebugDta   LikeDs( VEWL0100_t )  Inz( *LikeDs );
   dcl-s  moduleViews   Like  ( receiverVar_t );
   dcl-ds element       LikeDs( VEWL0100_elem )  Based( element_p );
   dcl-s  library       Like( TE_Name_t );
   dcl-s  timestamp     Like( TE_TimeStamp_t );
   dcl-s  viewIndex     Int ( 10 );
   dcl-s  iViewId       Int ( 10 );
   dcl-s  iViewLines    Int ( 10 );
   dcl-s  idx           Int ( 10 );
   dcl-s  brkModule     Like( TE_Name_t );

   //  Call QteRetrieveModuleViews to determine the number of bytes
   //  the receiver variable needs to be to hold all of the views for
   //  the program.
   RetrieveModuleViews( pgmDebugDta : %size( pgmDebugDta ) : 'VEWL0100'
                      : objToDebug  : objToDebugType : '*ALL' : library
                      : qteErrCode );
   if  qteErrCode.exceptId <> *blanks;
       Snd-Msg *Escape %msg( qteErrCode.exceptId : 'QCPFMSG' : qteErrCode.exceptData  )
               %target( *Caller : 3 );
   endIf;

   //  Get a buffer large enough to hold all view information           */
   RetrieveModuleViews( moduleViews : %size( moduleViews ) : 'VEWL0100'
                      : objToDebug  : objToDebugType : '*ALL' : library
                      : qteErrCode );
   if  qTeErrCode.exceptId <> *blanks;
       Snd-Msg *Escape %msg( qTeErrCode.exceptId : 'QCPFMSG' : qTeErrCode.exceptData  )
                       %target( *Caller : 3 );
   endIf;

   //  If number of elements is zero, program is not debuggable.       */
   pgmDebugDta = moduleViews;
   if  pgmDebugDta.NumElements  = 0;
       Snd-Msg *Escape 'Program ' + %trim( objToDebug.obj )
                    + ' in library ' + %trim( objToDebug.lib )
                    + ' cannot be debugged'
               %target( *Caller : 3 );
   endIf;

   //  Put the library returned by Retrieve Module Views in PgmLib
   objToDebug.lib = library;

   //  Register all views in the program
   element_p = %addr( moduleViews ) + 12;
   for idx  = 1 to pgmDebugDta.numElements;

       RegisterDebugView( iViewID : iViewLines : Library : TimeStamp
                        : objToDebug : objToDebugType
                        : element.ModuleName : element.ViewNumber
                        : qTeErrCode );
       if  qTeErrCode.exceptId <> *blanks;
           Snd-Msg *Escape %msg( qTeErrCode.exceptId : 'QCPFMSG' : qTeErrCode.exceptData  )
                   %target( *Caller : 3 );
       endIf;

       //  overwrite unneeded ViewNumber with obtained view id
       if  element.viewType  <> '*STATEMENT';
           if  element.ModuleName <> brkModule;
               brkModule  = element.ModuleName;
               c01mods += 1;
           endIf;
           WRT_Sfl01rcd( element.ModuleName : element.viewNumber
                       : element.viewType   : element.viewDescription );
           c01views += 1;
       endIf;

       element_p += %size( element );
   endFor;
end-proc;

//  ===============================================================  //
//  TearDownDebugger: End the debugger.                              //
//  ===============================================================  //
dcl-proc  TearDownDebugger;
   dcl-pi *n  end-pi;

   callp(e)  EndSourceDebug( qTeErrCode );
   if  qTeErrCode.exceptId <> *blanks;
       Snd-Msg *Escape %msg( qTeErrCode.exceptId : 'QCPFMSG' : qTeErrCode.exceptData  )
               %target( *Caller : 3 );
   endIf;
end-proc;

//  ===============================================================  //
//  Win01_Ctl                                                        //
//  ===============================================================  //
dcl-proc  Win01_Ctl;
   dcl-pi *n end-pi;
   // locals
   dcl-s  error         Ind;
   dcl-s  firstSelect   Ind;
   dcl-s  firstError    Ind;
   dcl-s  rtnCmdKey     Ind;

   //  Activate the window
   w01title = 'Select view(s) to retrieve source';
   write Win01D;
   //  Initialize window values
   exsr Win_Init;

   //  Window Display Control
   doW *on;

       dspInd.dspCtl01  = *on;
       dspInd.dspSfl01  = ( rrn01 > 0 );
       dspInd.dspSflErr = error;
       write Win01k;
       write Err01c;
       exfmt Win01c;

       //  Save current subfile position
       s01rcdNbr = dspf.SflRrnTop;
       //  Limpiar Errores
       CLR_PgmMsgQ( );
       error = *off;

       //  Control function keys that DO NOT require validation
       Select dspf.cmdkey;
         When-Is  F1;
             iter;
         When-Is  F3;
             leave;
         When-Is  F5;
             exsr Win_Refresh;
             iter;
         When-Is  F21;
             callp(e) qUsCmdLn( );
             iter;
       endSl;

       //  if subfile is empty, do not validate or process it
       if  rrn01 = 0;
           iter;
       endIf;

       //  validate window choices
       exsr Win_Check;
       if  error;
           iter;
       endif;

       //  execute window choices
       exsr Win_Exec;
       if  rtnCmdKey = F3;
           leave;
       endif;
       //  reactivate the window
       write  Win01D;
   EndDo;

   //  Initialize window values
   BegSr  Win_Init;

      c01pgm = %trim( objToDebug.lib ) + '/' + %trim ( objToDebug.obj );

      dspInd.sflEnd01 = *on;
      s01rcdNbr = 1;
   EndSr;

   //  refresh window
   BegSr  Win_Refresh;

      doU %eof( RtvDbgSrcD );
      readC Win01s;
          if  %eof( RtvDbgSrcD );
              leave;
          endIf;

          clear  s01option;
          dspInd.sflNxtChg = *off;
          update Win01s;
      endDo;
   EndSr;

   //  validate window choices
   BegSr  Win_Check;

      //  control first error for positioning
      firstSelect = *off;
      firstError  = *off;

      doU %eof( RtvDbgSrcD );
      readC Win01s;
          if  %eof( RtvDbgSrcD );
              leave;
          endif;

          //  restore subfile record error
          dspind.errOption = *off;

          //  mannage subfield next change 
          if  s01option = *blanks;
              dspInd.sflNxtChg = *off;
              update Win01s;
              iter;
          endif;

          //  check for valid option
          if  Not ( s01option In %list( '1' : '5' : '6' ));
              Snd-Msg *Info %msg( 'CAE9036' : 'QCPFMSG' )
                            %target( pgmName );
              dspind.errOption = *on;
              error  = *on;
          endif;

          //  control first error for positioning
          if  error and Not firstError;
              s01rcdNbr  = rrn01;
              firstError = *on;
          endif;
          //  update subfile record
          dspInd.sflNxtChg = *on;
          update Win01s;
      endDo;
   EndSr;

   //  execute window choices
   BegSr  Win_Exec;

      doU %eof( RtvDbgSrcD );
          readC Win01s;
          if  %eof( RtvDbgSrcD );
              leave;
          endif;

          viewText.ModName  = s01module;
          viewText.viewId   = %int( h01viewId );
          viewText.viewType = h01viewTyp;
          viewText.viewDesc = s01viewDes;

          textBuffer_p = %alloc( bufferSize );
          lineLength  = %size ( srcList );
          RetrieveViewText( textBuffer_p : bufferSize : viewText.viewId
                            : 1 : 72800 : lineLength : qTeErrCode );
          bufferOff_p  = textBuffer_p;
          if  viewText.viewType = '*LISTING';
              lineLength =  %size( srcList );
          endIf;

          //  If no saved information has been found for the selected
          //  view, switch to display mode.
          if  bufferOff.numLines = 0;
              s01option = '5';
          endIf;

          Select s01option;
            When-Is '1';
              rtnCmdKey = Win03_Ctl( );
              Select dspf.cmdkey;
                When-Is  F3;
                    leave;
                When-Is  F12;
                //> leave;
              endSl;
            When-Is '5';
              rtnCmdKey = Pnl02_Ctl( );
              Select dspf.cmdkey;
                When-Is  F3;
                    leave;
                When-Is  F12;
                //> leave;
              endSl;
            When-Is '6';
              PrtSource( );
          endSl;

          dealloc(N) textBuffer_p;
          clear  viewText;

          clear  s01option;
          dspInd.sflNxtChg = *off;
          update Win01s;
          s01rcdNbr = rrn01;

          if  rtnCmdKey = F12 and s01option = '1';
              leave;
          endIf;
      endDo;
   EndSr;
end-proc;

//  ===============================================================  //
//  CLEAR_Sfl01 -                                                    //
//  ===============================================================  //
dcl-proc  CLEAR_Sfl01;
   dcl-pi *n   end-pi;

   clear dspInd;
   clear Win01C;

   clear  rrn01;
   clear  s01rcdNbr;
   dspInd.dspCtl01 = *off;
   dspInd.dspSfl01 = *off;

   dspInd.clrSfl01 = *on;
   write Win01C;
   dspInd.clrSfl01 = *off;
end-proc;

//  ===============================================================  //
//  WRT_Sfl01Rcd -                                                   //
//  ===============================================================  //
dcl-proc  WRT_Sfl01Rcd;
   dcl-pi *n;
     i_ModName    Char( 10 ) Value;
     i_viewId     Int ( 10 ) Value;
     i_viewType   Char( 10 ) Value;
     i_viewDesc   Char( 50 ) Value;
   end-pi;

   clear Win01s;
   h01viewId  = i_viewId;
   h01viewTyp = i_viewType;
   s01module  = i_ModName;
   s01viewDes = i_viewDesc;

   rrn01   += 1;
   write Win01S;
end-proc;

//  ===============================================================  //
//  Pnl02_Ctl -                                                      //
//  ===============================================================  //
dcl-proc  Pnl02_Ctl;
   dcl-pi *n   Like( dspf.cmdkey );
   end-pi;
   // locals
   dcl-s  srcOffset      Int (  10 );
   dcl-s  debugCmd       Like( k02cmd );
   dcl-s  debugParm      Like( k02cmd );
   dcl-s  debugInt       Int (  10 );
   dcl-s  findWhat       VarChar( 140 );
   dcl-s  findFrom       Int (  10 );
   dcl-s  findPos        Int (  10 );
   dcl-s  allowBlanks    Ind;
   dcl-s  idx            Int (  10 );
   dcl-s  error          Ind;

   //  Initialize panel values
   exsr Pnl_Init;

   //  Panel Display Control
   doW *on;

       dspInd.dspCtl02 = *on;
       dspInd.dspSfl02 = ( rrn02 > 0 );
       dspInd.dspSflErr = error;
       write Pnl02c;
       if  Not dspInd.dspSfl02;
           w02NoSrc = RTV_CpfMsgTxt( 'CPF9C02' );
           write Pnl02noSrc;
       endIf;
       write Err02c;
       exfmt Pnl02k;

       //  save current cursor  position
       k02lin = %div( dspf.cursor : 256 );
       k02pos = %rem( dspf.cursor : 256 );
       //  save current subfile position
       if  dspf.SflRrnTop > 0;
           s02rcdNbr = dspf.SflRrnTop;
       endIf;
       //  Limpiar Errores
       CLR_PgmMsgQ( );
       error = *off;

       //  control function keys that DO NOT require validation
       Select dspf.cmdkey;
         When-Is  F1;
             iter;
         When-Is  F3;
             leave;
         When-Is  F5;
             exsr Pnl_Refresh;
             iter;
         When-Is  F12;
             leave;
         When-Is  F16;
             findFrom = s02RcdNbr + 1;
             exsr  Find_Str_Sfl02;
             iter;
         When-Is  F19;
             srcOffset = %max( 1 : srcOffset - 12 );
             exsr  Scroll_H_Sfl02;
             iter;
         When-Is  F20;
             srcOffset = %min( 1 + %size( h02txt ) - %size( s02txt )
                                 : srcOffset + 12 );
             exsr  Scroll_H_Sfl02;
             iter;
         When-Is  F21;
             callp(e) qUsCmdLn( );
             iter;
       endSl;

       if  K02Cmd = *blanks;
           iter;
       endif;

       //  validate panel choices
       exsr Pnl_Check;
       if  error;
           iter;
       endif;

       //  execute panel choices
       exsr Pnl_Exec;
   EndDo;

   return dspf.cmdKey;

   //  Initialize panel values
   BegSr  Pnl_Init;

      //  set default cursor position
      k02lin = 20;
      k02pos = 16;

      if  viewText.viewType  = '*LISTING';
          srcOffset   =  1;
      else;
          srcOffset   =  13;
      endIf;

      c02pgm = ObjToDebug.obj;
      c02lib = ObjToDebug.lib;
      c02mod = viewText.ModName;
      exsr   CLEAR_Sfl02;

      srcText_P  = textBuffer_p + %size( bufferOff );
      srcList_P  = textBuffer_p + %size( bufferOff );
      exsr  LOAD_Sfl02;
      //  view from the first record
      s02rcdNbr = 1;
   EndSr;

   //  refresh panel
   BegSr  Pnl_Refresh;
      clear K02Cmd;
   EndSr;

   //  validate panel choices
   BegSr  Pnl_Check;

      clear  debugCmd;
      clear  debugParm;
      clear  debugInt;
      allowBlanks = *off;

      K02Cmd = %trim( K02Cmd );
      idx  = %scan( ' ' : K02Cmd );
      debugCmd  = %upper( %subst( K02Cmd : 1 : idx ));
      debugParm = %subst( K02Cmd : idx + 1 );

      //  valid debug commands
      if  Not ( debugCmd  In %list( 'T' : 'TOP'   : 'BO' : 'BOTTOM'
                                  : 'U' : 'UP'    : 'DO' : 'DOWN'
                                  : 'L' : 'LEFT'  : 'R'  : 'RIGHT'
                                  : 'F' : 'FIND'  ));
          Snd-Msg *Info %msg( 'CPF9C43' : 'QCPFMSG' )
                        %target( pgmName );
          error = *on;
      //  debug commands that don't need a parameter value
      elseIf  debugCmd  In %list( 'T' : 'TOP' : 'BO' : 'BOTTOM' )
          and DebugParm <> *blanks;
          Snd-Msg *Info %msg( 'CPF9C59' : 'QCPFMSG' )
                        %target( pgmName );
          error = *on;
      //  debug commands that need a parameter value
      elseIf  debugCmd  In %list( 'U' : 'UP'    : 'DO' : 'DOWN'
                                : 'L' : 'LEFT'  : 'R'  : 'RIGHT'
                                : 'F' : 'FIND'  )
          and debugParm = *blanks;
          Snd-Msg *Info %msg( 'CPF9C59' : 'QCPFMSG' )
                        %target( pgmName );

      elseIf  debugCmd  In %list( 'U' : 'UP'    : 'DO' : 'DOWN'
                                : 'L' : 'LEFT'  : 'R'  : 'RIGHT' );
          monitor;
              debugInt = %int( %trim( debugParm ));
           on-error;
              Snd-Msg *Info %msg( 'CPF9C59' : 'QCPFMSG' )
                            %target( pgmName );
              error = *on;
          endMon;

      elseIf  debugCmd  In %list( 'F' : 'FIND' );
          monitor;
              debugInt = %int( %trim( debugParm ));
           on-error;
              RCV_PgmMsg( );
          endMon;
          if  debugInt = 0;
              findWhat = %trim( debugParm );
              if  %subst( findWhat : 1 : 1 ) = ''''
              and %subst( findWhat : %len( findWhat )) <> '''';
                  error = *on;
              elseif  %subst( findWhat : 1 : 1 ) <> ''''
                  and %subst( findWhat : %len( findWhat )) = '''';
                      error = *on;
              elseif  %subst( findWhat : 1 : 1 ) = ''''
                  and %subst( findWhat : %len( findWhat )) = '''';
                      findWhat = %subst( findWhat : 2 : %len( findWhat ) - 2 );
                      allowBlanks = *on;
              endIf;

              if  %scan( '''' : findWhat ) > 0
              or  %scan( ' '  : findWhat ) > 0 and Not allowBlanks;
                  error = *on;
              endIf;
          endIf;
      endIf;
   EndSr;

   //  execute panel choices
   BegSr  Pnl_Exec;

      select debugCmd;
        when-in %list( 'T'  : 'TOP' );
             s02RcdNbr = 1;
        when-in %list( 'BO' : 'BOTTOM' );
             s02RcdNbr = %min( 9984 : bufferOff.numLines - 14 );
        when-in %list( 'U'  : 'UP' );
             s02RcdNbr = %max( 1 : s02RcdNbr - debugInt );
        when-in %list( 'DO' : 'DOWN' );
             s02RcdNbr = %min( bufferOff.numLines - 14 : s02RcdNbr + debugInt );
        when-in %list( 'L'  : 'LEFT' );
             srcOffset = %max( 1 : srcOffset - debugInt );
             exsr  Scroll_H_Sfl02;
        when-in %list( 'R'  : 'RIGHT' );
             srcOffset = %min( 1 + %size( H02TXT ) - %size( S02TXT )
                                 : srcOffset + debugInt );
             exsr  Scroll_H_Sfl02;
        when-in %list( 'F'  : 'FIND' );
             if  debugInt > 0;
                 s02RcdNbr = %min( bufferOff.numLines : debugInt );
             else;
                 findFrom = s02RcdNbr;
                 exsr  Find_Str_Sfl02;
             endIf;
      endSl;

      clear K02Cmd;
      if  k02lin = 20;
          k02pos = 16;
      endIf;
   EndSr;

   //  CLEAR_Sfl02  ___________________________________________________
   BegSr  CLEAR_Sfl02;

      clear  rrn02;
      clear  s02rcdNbr;
      dspInd.dspCtl02 = *off;
      dspInd.dspSfl02 = *off;

      dspInd.clrSfl02 = *on;
      write Pnl02c;
      dspInd.clrSfl02 = *off;
   EndSr;

   //  LOAD_Sfl02  ____________________________________________________
   BegSr  LOAD_Sfl02;

      for idx = 1 to %min( bufferOff.numLines : 9999 );

          evalr s02seq = %char( idx );

          if  viewText.viewType = '*LISTING';
              s02txt = %subst( srcList : srcOffset );
              h02txt = srcList;
              srcList_P += bufferOff.lineLength;
          else;
              s02txt = %subst( srcText : srcOffset );
              h02txt = srcText;
              srcText_P += bufferOff.lineLength;
          endIf;

          rrn02   += 1;
          write Pnl02s;
      endFor;

      if bufferOff.numLines > 9999;
         Snd-Msg *Info %msg( 'RNQ0013' : 'QRNXMSG' )
                       %target( pgmName );
         error = *on;
      endIf;
   EndSr;

   //  Scroll_H_Sfl02  ________________________________________________
   BegSr  Scroll_H_Sfl02;

      for idx = 1 to %min( bufferOff.numLines : 9999 );

          chain  idx Pnl02s;
          s02txt = %subst( h02txt : srcOffset );
          update Pnl02s;
      endFor;
   EndSr;

   //  Find_Str_Sfl02  ________________________________________________
   BegSr  Find_Str_Sfl02;

      for idx = findFrom to %min( bufferOff.numLines : 9999 );

          chain  idx Pnl02s;
          findPos = %scan( %lower( findWhat ) : %lower( h02txt ));
          if  findPos > 0;
              s02rcdNbr = idx;
              if  Not ( findPos in %range( srcOffset : %size( s02txt )));
                  if  findPos + %len( findWhat ) < srcOffset + %size( s02txt );
                      srcOffset = findPos;
                      exsr  Scroll_H_Sfl02;
                  elseIf  findPos + %len( findWhat ) > srcOffset + %size( s02txt );
                      srcOffset = findPos + %len( findWhat ) - %size( s02txt );
                      exsr  Scroll_H_Sfl02;
                  endIf;
              endIf;
              k02lin  = 4;
              k02pos  = 10 + findPos - srcOffset;
              leave;
          endIf;
      endFor;
   EndSr;
end-proc;

//  ===============================================================  //
//  Win03_Ctl                                                        //
//  ===============================================================  //
dcl-proc  Win03_Ctl;
   dcl-pi *n    Like( dspf.cmdkey );
   end-pi;
   // locals
   dcl-ds rcvErrMsg     LikeDs( rcvm0100_t )  Inz( *LikeDs );
   dcl-s  wwQualSrcF    VarChar( 21 );
   dcl-s  redisply      Ind;
   dcl-s  error         Ind;

   //  Activate the window
   w03title = 'Retrieve ' + %trim( viewText.viewDesc );
   write Win03D;
   //  Initialize window values
   exsr Win_Init;

   //  Window Display Control
   doW *on;

       dspInd.dspSflErr = error;
       write Err03c;
       exfmt Win03;

       //  Limpiar Errores
       exsr Win_ResetError;

       //  Control function keys that DO NOT require validation
       Select dspf.cmdkey;
         When-Is  F1;
             iter;
         When-Is  F3;
             leave;
         When-Is  F5;
             exsr Win_Init;
             iter;
         When-Is  F12;
             leave;
         When-Is  F21;
             callp(e) qUsCmdLn( );
             iter;
       endSl;

       //  validate window choices
       exsr Win_Check;
       if  error;
           iter;
       elseIf  redisply;
           iter;
       endif;

       //  execute window choices
       exsr Win_Exec;
       if  error;
           iter;
       endif;
       leave;
   EndDo;

   return dspf.cmdKey;

   //  Initialize window values
   BegSr  Win_Init;

      w03pgm  = ObjToDebug.obj;
      w03lib  = ObjToDebug.lib;
      w03mod  = viewText.ModName;

      //> w03srcF = 'QRPGLESRC';
      w03srcL = '*LIBL';
      w03srcM = '*MODULE';
   EndSr;

   BegSr  Win_ResetError;

      CLR_PgmMsgQ( );

      dspInd.errSrcF   = *off;
      dspInd.errSrcL   = *off;
      dspInd.errSrcM   = *off;
      dspInd.errLinOpt = *off;
      error     = *off;
      redisply  = *off;
   EndSr;

   //  validate window choices
   BegSr  Win_Check;

      if  w03srcL  = *blanks;
          w03srcL  = '*LIBL';
          redisply = *on;
      endif;

      if  w03srcM  = *blanks;
          w03srcM  = '*MODULE';
          redisply = *on;
      endif;

      if  w03srcF  = *blanks;
          Snd-Msg *Info %msg( 'CPF3C5C' : 'QCPFMSG' : w03srcF + w03srcL )
                        %target( pgmName );
          dspInd.errSrcF  = *on;
          dspInd.errSrcL  = *on;
          error    = *on;
      endif;
   EndSr;

   //  execute window choices
   BegSr  Win_Exec;

     wwQualSrcF = %trim( w03srcL ) + '/' + %trim( w03srcF );
     sysCmd = 'AddPfm  File(' + wwQualSrcF + ')'
            + ' Mbr(' + %trim( w03srcM ) + ') SrcType(DbgView)'
            + ' Text( ''' + %trim( viewText.viewDesc ) + ''')';
     callp(e) ExecCmd( %trim( sysCmd ) : %len( sysCmd ));
     if  %error( );
         exsr  RESND_PgmMsg;
         error = *on;
         leaveSr;
     endIf;

     SavSource( wwQualSrcF : %trim( w03srcM ));
   EndSr;

   BegSr  RESND_PgmMsg;

      RcvPgmMsg( rcvErrMsg : %len( rcvErrMsg ) : 'RCVM0100'
               : '*' : 0 : '*ESCAPE' : ' ' : 0 : '*REMOVE' : mhErrCode );
      RcvPgmMsg( rcvErrMsg : %len( rcvErrMsg ) : 'RCVM0100'
               : '*' : 0 : '*ANY'    : ' ' : 0 : '*REMOVE' : mhErrCode );
      if  rcvErrMsg.msgId > *blanks;
          Snd-Msg  *Diag %msg( rcvErrMsg.msgId : 'QCPFMSG' : rcvErrMsg.rplDta )
                   %target( pgmName );
      endIf;
   EndSr;
end-proc;

//  ===============================================================  //
//  SavSource -                                                      //
//  ===============================================================  //
dcl-proc  SavSource;
   dcl-pi *n;
     i_qualSrcF   VarChar( 21 )  Value;
     i_SrcM       VarChar( 10 )  Value;
   end-pi;
   dcl-f  qRpgLeSrc  Disk( 112 )  Usage( *OutPut )
                                  ExtFile( i_qualSrcF )
                                  ExtMbr ( i_SrcM )
                                  UsrOpn;
   dcl-s  qualSrcF   VarChar( 21 );
   dcl-ds srcStmt    Qualified;
             seq     Char(   6 );
             dat     Char(   6 );
             dta     Char( 100 );
   end-ds;
   // locals
   dcl-s  idx        Int (  10 );

   open  qRpgLeSrc;

   srcText_p = textBuffer_p + %size( bufferOff );
   srcList_p = textBuffer_p + %size( bufferOff );
   for idx = 1 to bufferOff.numLines;
       if  viewText.viewType = '*LISTING';
           exsr  WriteStmt;
       else;
           exsr  WriteText;
       endIf;
   endFor;

   close qRpgLeSrc;

   //> WriteText  _____________________________________________________
   BegSr  WriteText;

       srcStmt.Seq = srcText.Seq;
       srcStmt.Dat = srcText.Dat;
       srcStmt.Dta = srcText.Dta;

       write qRpgLeSrc  srcStmt;
       srcText_p  += bufferOff.lineLength;
   EndSr;
   //> WriteStmt  _____________________________________________________
   BegSr  WriteStmt;

      evalR  srcStmt.Seq = %editc( idx : 'X' );
      srcStmt.Dat = *all'0';
      srcStmt.Dta = srcList;
      //> srcStmt.Dta = %subst( srcList : 10 ); ?? 

      write qRpgLeSrc  srcStmt;
      srcList_p  += bufferOff.lineLength;
   EndSr;
end-proc;

//  ===============================================================  //
//  PrtSource -                                                      //
//  ===============================================================  //
dcl-proc  PrtSource;
   dcl-pi *n end-pi;

   dcl-f  qSysPrt printer( 132 )  PrtCtl( prtCtl )
                                  OflInd( *in98 ) UsrOpn;
   dcl-ds prtCtl     Qualified;
             spaceB  Char ( 3 );
             spaceA  Char ( 3 );
             skipB   Char ( 3 );
             skipA   Char ( 3 );
             currLin Zoned( 3 );
   end-ds;
   dcl-s  prtPage    Int (   5 );
   dcl-ds prtLine    Len ( 132 )  end-ds;
   dcl-ds prtText    Len ( 132 )  Qualified;
             seq     Char(   6 )  Pos(   2 );
             dta     Char( 110 )  Pos(   9 );
             dat     Char(   8 )  Pos( 121 );
   end-ds;
   // locals
   dcl-s  idx            Int (  10 );

   exsr  OpenPrtF;
   exsr  PrintHeader;

   srcText_P  = textBuffer_p + %size( bufferOff );
   srcList_P  = textBuffer_p + %size( bufferOff );
   for idx = 1  to bufferOff.numLines;
       if  viewText.viewType  = '*LISTING';
           exSr  PrintStmt;
           srcList_P += bufferOff.lineLength;
       else;
           exSr  PrintText;
           srcText_P += bufferOff.lineLength;
       endIf;
   endFor;

   close qSysPrt;

   //> PrintHeader  ___________________________________________________
   BegSr  PrintHeader;

      clear prtCtl;
      prtCtl.SkipB = '001';
      prtPage += 1;

      clear   prtLine;
      %subst( prtLine : 40 )  = 'Retrieved source from debug [RTVDBGSRC]';
      %subst( prtLine : 123 ) = 'Pag.' + %editC( prtPage : 'Z' );
      write qSysPrt prtLine;

      clear prtCtl;
      prtCtl.SpaceB = '002';
      %subst( prtLine :  3 ) = 'Object  . . . . . . . . .';
      %subst( prtLine : 30 ) = %trim( objToDebug.lib ) + '/' + %trim ( objToDebug.obj );
      write qSysPrt prtLine;

      prtCtl.SpaceB = '001';
      %subst( prtLine :  3 ) = 'Member  . . . . . . . . .';
      %subst( prtLine : 30 ) = viewText.ModName + ' - ' + viewText.viewDesc;
      write qSysPrt prtLine;

      prtCtl.SpaceB = '002';
      prtLine = '  SEQNBR*...+... 1 ...+... 2 ...+... 3 ...+... 4 ...+... 5'
              +          '...+... 6 ...+... 7 ...+... 8 ...+... 9 ...+... 0';
      write qSysPrt prtLine;

      clear prtCtl;
      prtCtl.SpaceB = '001';
      *in98 = *off;
   EndSr;
   //> PrintText  _____________________________________________________
   BegSr  PrintText;

      if  *in98;
          exsr  PrintHeader;
      endIf;

      clear prtText;
      prtText.seq = %editc( %dec( srcText.seq : 6 : 0 ) : 'Z' );
      prtText.dta = srcText.dta;
      prtText.dat = %editc( %dec( srcText.dat : 6 : 0 ) : 'Y' );
      write(e) qSysPrt prtText;
   EndSr;
   //> PrintStmt  _____________________________________________________
   BegSr  PrintStmt;

      if  *in98;
          exsr  PrintHeader;
      endIf;

      prtText  = srcList;
      write(e) qSysPrt prtText;
   EndSr;
   //> OpenPrtF  ______________________________________________________
   BegSr  OpenPrtF;

      sysCmd = 'OvrPrtF qSysPrt PageSize(90 132) Lpi(8) Cpi(20)'
                                +   ' OvrFlw(84) OvrScope(*job)';
      callp(e) ExecCmd( %trim( sysCmd ) : %len( sysCmd ));
      open qSysPrt;
      *in98 = *off;
   EndSr;
end-proc;

//  ===============================================================  //
//  CLR_PgmMsgQ                                                      //
//  ===============================================================  //
dcl-proc  CLR_PgmMsgQ;
   dcl-pi *n  end-pi;
   dcl-ds mhErrorCode   LikeDs( errCode_t )   Inz( *LikeDs );

   RmvPgmMsg( pgmName : 0 : *blanks : '*ALL' : mhErrorCode );
end-proc;

//  ===============================================================  //
//  RCV_PgmMsg                                                       //
//  ===============================================================  //
dcl-proc  RCV_PgmMsg;
   dcl-pi *n  end-pi;
   dcl-ds rcvErrMsg     LikeDs( rcvm0100_t )  Inz( *LikeDs );
   dcl-ds mhErrorCode   LikeDs( errCode_t )   Inz( *LikeDs );

   RcvPgmMsg( rcvErrMsg : %len( rcvErrMsg ) : 'RCVM0100' : '*' : 1
            : '*ANY'    : ' ' : 0 : '*REMOVE' : mhErrorCode );
end-proc;

//  ===============================================================  //
//  RTV_CpfMsgTxt                                                    //
//  ===============================================================  //
dcl-proc  RTV_CpfMsgTxt;
   dcl-pi *n  VarChar( 80 );
     i_msgId  Char( 7 ) Const;
   end-pi;
   dcl-s  msgText       VarChar( 80 );
   dcl-ds rtvMsgInfo    LikeDs( rtvm0100_t )  Inz;
   dcl-ds mhErrorCode   LikeDs( errCode_t )   Inz( *LikeDs );

   RetrieveMsg( rtvMsgInfo : %len( rtvMsgInfo ) : 'RTVM0100' : i_msgId
              : 'QCPFMSG   *LIBL' : *blanks : 0 : '*NO' : '*NO'
              : mhErrorCode );
   if  mhErrorCode.exceptId <> *blanks;
       Snd-Msg *Info %msg( mhErrorCode.exceptId : 'QCPFMSG' : mhErrorCode.exceptData )
               %target( pgmName );
   elseIf  rtvMsgInfo.lenMsgRetrn > 0;
       msgText = %subst( rtvMsgInfo.msgText : 1 : rtvMsgInfo.lenMsgRetrn );
   endif;
   return  msgText;
end-proc;
