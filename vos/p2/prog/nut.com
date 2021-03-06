$!****************************************************************************
$!
$! Build proc for MIPL module nut
$! VPACK Version 1.8, Wednesday, March 13, 1996, 09:29:06
$!
$! Execute by entering:		$ @nut
$!
$! The primary option controls how much is to be built.  It must be in
$! the first parameter.  Only the capitalized letters below are necessary.
$!
$! Primary options are:
$!   COMPile     Compile the program modules
$!   ALL         Build a private version, and unpack the PDF and DOC files.
$!   STD         Build a private version, and unpack the PDF file(s).
$!   SYStem      Build the system version with the CLEAN option, and
$!               unpack the PDF and DOC files.
$!   CLEAN       Clean (delete/purge) parts of the code, see secondary options
$!   UNPACK      All files are created.
$!   REPACK      Only the repack file is created.
$!   SOURCE      Only the source files are created.
$!   SORC        Only the source files are created.
$!               (This parameter is left in for backward compatibility).
$!   PDF         Only the PDF file is created.
$!   TEST        Only the test files are created.
$!   IMAKE       Only the IMAKE file (used with the VIMAKE program) is created.
$!
$!   The default is to use the STD parameter if none is provided.
$!
$!****************************************************************************
$!
$! The secondary options modify how the primary option is performed.
$! Note that secondary options apply to particular primary options,
$! listed below.  If more than one secondary is desired, separate them by
$! commas so the entire list is in a single parameter.
$!
$! Secondary options are:
$! COMPile,ALL:
$!   DEBug      Compile for debug               (/debug/noopt)
$!   PROfile    Compile for PCA                 (/debug)
$!   LISt       Generate a list file            (/list)
$!   LISTALL    Generate a full list            (/show=all)   (implies LIST)
$! CLEAN:
$!   OBJ        Delete object and list files, and purge executable (default)
$!   SRC        Delete source and make files
$!
$!****************************************************************************
$!
$ write sys$output "*** module nut ***"
$!
$ Create_Source = ""
$ Create_Repack =""
$ Create_PDF = ""
$ Create_Test = ""
$ Create_Imake = ""
$ Do_Make = ""
$!
$! Parse the primary option, which must be in p1.
$ primary = f$edit(p1,"UPCASE,TRIM")
$ if (primary.eqs."") then primary = " "
$ secondary = f$edit(p2,"UPCASE,TRIM")
$!
$ if primary .eqs. "UNPACK" then gosub Set_Unpack_Options
$ if (f$locate("COMP", primary) .eqs. 0) then gosub Set_Exe_Options
$ if (f$locate("ALL", primary) .eqs. 0) then gosub Set_All_Options
$ if (f$locate("STD", primary) .eqs. 0) then gosub Set_Default_Options
$ if (f$locate("SYS", primary) .eqs. 0) then gosub Set_Sys_Options
$ if primary .eqs. " " then gosub Set_Default_Options
$ if primary .eqs. "REPACK" then Create_Repack = "Y"
$ if primary .eqs. "SORC" .or. primary .eqs. "SOURCE" then Create_Source = "Y"
$ if primary .eqs. "PDF" then Create_PDF = "Y"
$ if primary .eqs. "TEST" then Create_Test = "Y"
$ if primary .eqs. "IMAKE" then Create_Imake = "Y"
$ if (f$locate("CLEAN", primary) .eqs. 0) then Do_Make = "Y"
$!
$ if (Create_Source .or. Create_Repack .or. Create_PDF .or. Create_Test .or -
        Create_Imake .or. Do_Make) -
        then goto Parameter_Okay
$ write sys$output "Invalid argument given to nut.com file -- ", primary
$ write sys$output "For a list of valid arguments, please see the header of"
$ write sys$output "of this .com file."
$ exit
$!
$Parameter_Okay:
$ if Create_Repack then gosub Repack_File
$ if Create_Source then gosub Source_File
$ if Create_PDF then gosub PDF_File
$ if Create_Test then gosub Test_File
$ if Create_Imake then gosub Imake_File
$ if Do_Make then gosub Run_Make_File
$ exit
$!
$ Set_Unpack_Options:
$   Create_Repack = "Y"
$   Create_Source = "Y"
$   Create_PDF = "Y"
$   Create_Test = "Y"
$   Create_Imake = "Y"
$ Return
$!
$ Set_EXE_Options:
$   Create_Source = "Y"
$   Create_Imake = "Y"
$   Do_Make = "Y"
$ Return
$!
$ Set_Default_Options:
$   Create_Source = "Y"
$   Create_Imake = "Y"
$   Do_Make = "Y"
$   Create_PDF = "Y"
$ Return
$!
$ Set_All_Options:
$   Create_Source = "Y"
$   Create_Imake = "Y"
$   Do_Make = "Y"
$   Create_PDF = "Y"
$ Return
$!
$ Set_Sys_Options:
$   Create_Source = "Y"
$   Create_Imake = "Y"
$   Create_PDF = "Y"
$   Do_Make = "Y"
$ Return
$!
$Run_Make_File:
$   if F$SEARCH("nut.imake") .nes. ""
$   then
$      vimake nut
$      purge nut.bld
$   else
$      if F$SEARCH("nut.bld") .eqs. ""
$      then
$         gosub Imake_File
$         vimake nut
$      else
$      endif
$   endif
$   if (primary .eqs. " ")
$   then
$      @nut.bld "STD"
$   else
$      @nut.bld "''primary'" "''secondary'"
$   endif
$ Return
$!#############################################################################
$Repack_File:
$ create nut.repack
$ DECK/DOLLARS="$ VOKAGLEVE"
$ vpack nut.com -
	-s nut.banner -
	-i nut.imake -
	-p nut.pdf -
	-t tstnut.pdf
$ Exit
$ VOKAGLEVE
$ Return
$!#############################################################################
$Source_File:
$ create nut.banner
$ DECK/DOLLARS="$ VOKAGLEVE"
procedure
refgbl $syschar
body
if ($syschar(1) = "VAX_VMS")
  dcl write sys$output " "
  dcl write sys$output " "
  dcl write sys$output "***************************************"
  dcl write sys$output "*                                     *"
  dcl write sys$output "*       VICAR NEW USER TUTORIAL       *"
  dcl write sys$output "*                                     *"
  dcl write sys$output "***************************************"
  dcl write sys$output " "
  dcl write sys$output " "
  dcl write sys$output " "
  dcl write sys$output " "
  dcl write sys$output " "
  dcl write sys$output " "
  dcl wait 0:00:03.0
else
  write  " "
  write  " "
  write  "***************************************"
  write  "*                                     *"
  write  "*       VICAR NEW USER TUTORIAL       *"
  write  "*                                     *"
  write  "***************************************"
  write  " "
  write  " "
  write  " "
  write  " "
  write  " "
  ush sleep 3 
end-if
end-proc
$ VOKAGLEVE
$ Return
$!#############################################################################
$Imake_File:
$ create nut.imake
#define  PROCEDURE nut
#define R2LIB

$ Return
$!#############################################################################
$PDF_File:
$ create nut.pdf
procedure help=*
refgbl $echo
refgbl $syschar
body
!
! Display the NUT banner with a 3 second delay.
!
nut.banner
!
! Err is a dummy to show how an error looks.
!
procedure name=err
body
dummy1
end-proc
!
! Exec sets up the normal NUT> prompt, fields the operator response
! and then executes the operator entered command from a local variable.
!
procedure name=exec
PARM FLAG STRING DEFAULT=OFF VALID=(ON,OFF) COUNT=1
PARM PAUSE KEYWORD VALID=PAUSE DEFAULT=--   COUNT=0:1
BODY
let _onfail="GOTO ERR"
LOCAL CMD string
IF ($COUNT(PAUSE) )
	WRITE " "
	WRITE "Press RETURN to proceed..."
	WRITE " "
END-IF
FLAG-ADD NOMESSAGE
if ($syschar(1) = "VAX_VMS")
nutprompt line=24 col=1 lfcr=0
else
nutprompt line=23 col=1 lfcr=0
end-if
NUTINP CMD
!	WRITE "Back from nutimp..."
!disp cmd
FLAG-DELETE NOMESSAGE
IF (CMD = "CONTINUE") 
	RETURN
ELSE-IF (CMD = "QUIT")
	STOP
END-IF
IF (FLAG = "ON") LET $ECHO=("TRACE")
&CMD
IF (FLAG = "ON") LET $ECHO=("NO")
return
ERR>write " "
write "Got an error here.  The last command was probably mistyped."
write "This is what you typed:"
write @cmd
write "Try retyping correctly, type CONTINUE to proceed anyway or"
write "QUIT to quit"
write " "
exec
end-proc
!
!************************************************************************
! This is the body of Nut.  All of the test displayed is in the following.
!************************************************************************
!
disable-log
write " "
write "Welcome to the VICAR NEW USER'S TUTORIAL"
write " "
write "    This is a training session in basic VICAR concepts and functions."
if ($syschar(1) = "VAX_VMS")
write "This session is for users familiar with DCL (DEC's Command Language"
write "under VMS), but not with VICAR.  Users not familiar with DCL are"
write "advised to run the VMSCAI tutorial in DCL.  "
else
write "This session is for users familiar with UNIX's CSH or USH, (C Shell-"
write "Command Interpreter and High-level Programming Language),"
write "but not with VICAR.  Users not familiar with C Shell Commands are"
write "advised to run the 'man list' under the login % prompt for a listing of"
write "the UNIX Commands, as well as, 'man xxx' where xxx is the Command"
write "for a detailed explanation and syntax.  'man tcsh' explains the C Shell."
end-if
write "    This tutorial introduces common VICAR operations, with the"
write "detailed descriptions left to the VICAR USER'S GUIDE.  A copy of"
write "the VICAR USER'S GUIDE should be kept handy because the last Section"
write "thereof contains a printed version of this tutorial for reference."
write "    This tutorial will, at times, instruct the user to type various"
write "commands.  Follow all such commands with a Carriage Return.  It will"
write "behoove the tutee to make the entries exactly as requested, lest the"
if ($syschar(1) = "VAX_VMS")
write "tutor become confused."
else
write "tutor become confused.  UNIX is case sensitive, thus all entries"
write "should be made in lower case unless directed otherwise."
end-if
exec 'PAUSE flag="on"
write ".................................................................."
write ".......................EXITING THIS SESSION......................."
write ".................................................................."
write "    When finished, the best way to end this tutorial at any"
write "       prompt is to type QUIT.  If you want to skip portions of this" 
FLAG-ADD NOMESSAGE
if ($syschar(1) = "VAX_VMS")
nutprompt line=24 col=1 lfcr=1
else
nutprompt line=23 col=1 lfcr=1
end-if
FLAG-DELETE NOMESSAGE
write "tutorial, just respond with Carriage Return at the prompts."
write "Of course, some steps require the results of previous steps, so "
write "watch out.  To leave NUT and VICAR, type EXIT when you are at the"
write "       prompt. "
FLAG-ADD NOMESSAGE
if ($syschar(1) = "VAX_VMS")
nutprompt line=24 col=1 lfcr=1
else
nutprompt line=23 col=1 lfcr=1
end-if
FLAG-DELETE NOMESSAGE
if ($syschar(1) = "VAX_VMS")
write "    You can always get out of any VICAR operation (including this"
write "tutorial) with a CONTROL-Y keystroke if you are desparate (your "
write "entire VICAR session will end).  A more graceful way to abort any"
write "VICAR operation is with a CONTROL-C keystroke.  You will be"
write "prompted by the interrupt handler.  "
else
write "    You can always get out of any VICAR operation (including this"
write "tutorial) with a CONTROL-C keystroke.  The NUT procedure will be"
write "interrupted and VICAR will be in the interrupt mode."
end-if
write " "
write "To abort the operation, but remain in VICAR, respond with:  ABORT"
write "To continue the operation, respond with:  CONTINUE  "
write " "
write "Try this now.  Type CONTROL-C, but respond with CONTINUE to return here."
if ($syschar(1) = "VAX_VMS")
else
write "A second  ENTER or RETURN may be necessary after the  CONTINUE  ."
end-if
write " "
exec
write " "
write "Good, you made it back.  Now on to the meat of the tutorial."
write " "
write ".............................................................."
write "................SAVING YOUR SESSION LOG......................."
write ".............................................................."
write "    Because this is a training session, you should have a listing of"
write "this interactive session for future reference.  Therefore, before"
write "you go any further, tell VICAR to save this session in a file to"
write "print later.  Type ENABLE-LOG."
write " "
exec
write " "
write "    What you just entered is known as an Intrinsic command.  If you "
write "want to get technical, ENABLE was the command and LOG was the "
write "sub-command. You will be doing more of those later in this session."
write "A list of the available Intrinsic commands may be found in the"
write "VICAR USER'S GUIDE Section 10.4 or you can use HELP (see below)."
write " "
write ".................................................................."
write ".......................USING VICAR HELP..........................."
write ".................................................................."
write "    VICAR makes available several kinds of user aids.  The most "
write "obvious is the extensive HELP utility.  To find out its capabilities,"
write "ask for HELP on the HELP command by typing HELP HELP.  Within the"
write "utility, type any of the listed choices, but end by typing EXIT."
write "Now, type HELP HELP and return here with EXIT."
write " "
exec
write " "
write "    Now that you have read about HELP, run it to get information on"
write "available Intrinsic Commands.  These are commands which interact"
write "with the VICAR Executive rather than execute programs.  As a matter"
write "of fact, you have already used such Intrinsic Commands.  You "
write "used ENABLE-LOG and HELP.  "
write "    Type HELP and page through the text to see what other "
write "Intrisic Commands are available, and end with EXIT to return here."
write " "
exec
write " "
write "    Get HELP on an individual command.  Type HELP ENABLE-LOG and return "
write "here with EXIT ."
write " "
exec
write " "
write "    To obtain general HELP on VICAR, type HELP VICAR, type any listed" 
write "choices and return here with EXIT."
write " "
exec
write " "
write "    There is also HELP on more specific areas of VICAR.  For instance,"
write "information on a particular program may be requested. Type HELP COPY"
write "and return here with EXIT ."
write " "
exec
write " "
write "    Another HELP function deserves mentioning.  You may wish "
write "to have the documentation for specific programs written to a "
write "disk file in your directory.  The file thus created may be listed"
write "on terminal or line printer.  Use HELP's subcommand -HARDCOPY to "
write "get the documentation, for program COPY, type HELP-HARDCOPY COPY."
write " "
exec
write " "
write "    Check your directory for that documentation file.  Type"
if ($syschar(1) = "VAX_VMS")
write "DIR COPY.MEM  ."
else
write "LS -L COPY.MEM  ."
end-if
write " "
exec
write " "
write ".................................................................."
write ".......................GETTING HELP ON ERRORS....................."
write ".................................................................."
write "    Occasionally, users will make errors.  VICAR will respond with a"
write "brief error message.  For example:"
write " "
let _onfail=("CONTINUE","RETURN")
err
let _onfail="RETURN"
write " "
write "    At this point, you can obtain a more detailed description of the "
write "error.  You may access HELP for the last error by just typing: ? "
write "After reading the explanatory text, you return to your session "
write "by typing: EXIT "
write "    Try this on that error we got, Type ? ."
write " "
exec
write " "
write ".................................................................."
write ".......................VICAR LIBRARIES............................"
write ".................................................................."
write "    Now that you are in the VICAR environment, you have access not"
write "only to the files in your directories, but also to the numerous VICAR"
write "libraries of utilities and applications programs.  Whenever you"
write "attempt to execute such a VICAR utility or program, VICAR searches"
write "its libraries to find the name that you requested.  To see what "
write "libraries you are accessing, use the Intrinsic Command SHOW."
write "Type SHOW."
write " "
exec
write "    The Command SHOW lists User Library first ($USERLIB), followed"
write "by Application Libraries ($APLIB) and System Library ($SYSLIB)."
if ($syschar(1) = "VAX_VMS")
write "To see what Application Libraries are, Type DCL SHOW LOGICAL LIBLST."
end-if
write " "
exec
write "    The search hierarchy begins with your directory (at the top) and"
write "works its way down until the module is located.  To illustrate"
write "this, I will arrange for the module's library name to be listed"
write "when a module is executed.  Try invoking the module V2VERSION."
write "Type V2VERSION to see where that module is found."
write " "
exec ON
write " "
if ($syschar(1) = "VAX_VMS")
write "    That module was found in MIPL:[VICAR.LIB.XXX-VMS], aka V2$SYSLIB"
write "where 'XXX' is the machine type, i.e. VAX, AXP."
else
write "    That module was found in /usr/local/vicar/../lib/.../, "
write "where ".." is "ops" or "dev" and "..." is the machine type i.e. sun-4."
end-if
write "If you had a V2VERSION in your directory, VICAR would have used"
write "your version."
write " "
write "    You may change the order of the libraries (directories) or add "
write "to the hierarchy.  Use the Intrinsic Command to put the directory"
write "pointed at by the logical name STARLIB into the hierarchy."
write "Type SETLIB (STARLIB:,*)."
write " "
exec
write " "
write "Check the results by again typing SHOW."
write " "
exec
write "    Notice that the new library went ahead of all the others, except"
write "your current default directory.  All the others was represented by"
write "the * in the SETLIB command."
write " "
write "    Getting rid of a search directory is just as simple.  Type "
write "SETLIB-DELETE STARLIB: ."
write " "
exec
write " "
write "Now verify the action with another SHOW"
write " "
exec
write ".................................................................."
if ($syschar(1) = "VAX_VMS")
write ".......................VICAR DCL MODE............................."
write "    VICAR provides a way to execute DCL commands while still in the"
write "VICAR environment.  In the DCL Mode of VICAR, almost all DCL commands"
write "will function.  Now get into DCL mode."
write " "
write "Type: DCL ."
write "At the DCL Mode prompt, _$, execute a DCL command like SHOW TERMINAL ."
write "To return to VICAR, type: VICAR or EXIT (at the DCL mode prompt)."
else
write ".......................VICAR USH MODE............................."
write "    VICAR provides a way to execute user Shell commands while still in"
write "the VICAR environment.  In the USH Mode of VICAR, almost all Shell"
write "Commands will function.  Now get into USH mode."
write " "
write "Type: USH ."
write "At the shell prompt, {prompt}%, execute a Shell command like PS -L ."
write "To return to VICAR, type: EXIT (at the shell prompt)."
end-if
write ".................................................................."
write " "
exec
write " "
if ($syschar(1) = "VAX_VMS")
write "    DCL commands may also be executed without leaving VICARs "
write "command mode.  Type DCL SHOW PROCESS."
else
write "    USH commands may also be executed without leaving VICARs "
write "command mode.  Type USH PS -L."
end-if
write " "
exec
if ($syschar(1) = "VAX_VMS")
dcl wait 0:00:03.0
else
ush sleep 3
end-if
write " "
write ".................................................................."
write ".......................VICAR TUTOR MODE..........................."
write ".................................................................."
write "    Up to now, you have been interacting with VICAR in Command mode."
write "There will be more of that a little later, but users need the"
write "ability to invoke programs or procedures to do the bulk of their"
write "work.  VICAR has the capability to assist users in running such"
write "modules.  The mode called TUTOR allows users to have access "
write "to HELP on parameters while defining parameter values."
write " "
write "Invoke the TUTOR for module GEN by typing:     TUTOR GEN  "
write "At the TUTOR prompt, give parameter "
write "    OUT the value +A:                          OUT=+A "
write "Save this set of parameter "
write "    values (including defaults):               SAVE  "
write "Return here without executing the module:      EXIT  "
write " "
write "    These instructions will disappear while you are in TUTOR," 
write "but this session is listed in the VICAR USER'S GUIDE."
write "Start with TUTOR GEN."
write " "
exec
write " "
write "    You gave the parameter OUT a value of +A, saved those parameter"
write "values for later and then EXITed.  Now bring those parameter "
write "values back and run the program GEN.  "
write " "
write "Invoke the TUTOR for module GEN:    TUTOR GEN  "
write "At the TUTOR prompt, recall "
write "the SAVEd set of parameter values:  RESTORE    "
write "Let the module execute:             RUN        "
write " "
write "    You will return here after the program GEN is completed."
write "Start by typing TUTOR GEN."
write " "
exec
write " "
write ".................................................................."
write ".......................VICAR DATASET NAMES........................"
write ".................................................................."
write "    You have created an image with characteristics based upon the"
write "program defaults and user-input parameter values.  Now do a "
if ($syschar(1) = "VAX_VMS")
write "directory on it.  Type DCL DIR VTMP:[000000]A  ."
else
write "directory on it.  Type USH LS -L $VTMP/A  . 'VTMP' must be in caps."
end-if
write " "
exec
if ($syschar(1) = "VAX_VMS")
dcl wait 0:00:03.0
else
ush sleep 3
end-if
write " "
if ($syschar(1) = "VAX_VMS")
write "    Note that the file has a 'dot Z' file type.  If no file type is "
write "specified by the user for a file, this is what is created.  The"
write "numbers after the Z are process-specific.  ALL FILES WITH SUCH"
write "'DOT Z' QUALIFIERS ARE DELETED AT LOGOFF."
end-if
write " "
write "    Note that the '+' preceeding A indicated to VICAR to create a"
if ($syschar(1) = "VAX_VMS")
write "temporary file in the directory VTMP:[000000].  If the directory"
write "did not exist it was created and the file saved in it.  THE FILE IS"
write "AUTOMATICALLY DELETED AT LOGOFF."
write "Without the '+' preceeding A, the file would be created in your user"
write "directory.  By using the '+', the automatic delete will only have to"
write "search and delete in the temporary directory rather than the entire"
write "disk as it does now at logoff."
else
write "temporary file in the directory /tmp/{user name}/.  If the directory"
write "did not exist it was created and the file saved in it.  THE FILE AND"
write "{user name} DIRECTORY ARE AUTOMATICALLY DELETED ON A PERIODIC BASIS."
write "Without the '+' preceeding A, the file would be created in your user"
write "directory, and should be deleted when no longer needed."
end-if
write " "
write ".................................................................."
write ".......................VICAR LABELS..............................."
write ".................................................................."
write "    As with all VICAR files, the file that you GEN'd has a"
write "VICAR label.  List out the label with the program LABEL by "
write "typing LABEL-LIST INP=+A  ."
write " "
exec
write " "
write "    The label not only contains the file attributes, but may hold "
write "user- or program-supplied label items.  Add a comment using the "
write "program LABEL by typing :"
write "      LABEL-ADD INP=+A OUT=+B ITEMS=""COMMENT='HOWDY'""    ."
write " "
exec
write " "
write "    List the label again by typing "
write "          LABEL-LIST INP=+B    .  "
write "Notice that the added label appears below the previously added items."
write " "
exec
if ($syschar(1) = "VAX_VMS")
dcl wait 0:00:03.0
else
ush sleep 3
end-if
write " "
write ".................................................................."
write ".....................COMMAND LINE SYNTAX.........................."
write ".................................................................."
write "   The last couple of lines you typed actually invoked programs rather"
write "than Intrinsic Commands.  Notice that the command line consisted of:"
write " "
write "1) a PROGRAM or PROCEDURE name for VICAR to find and execute,"
write " "
write "2) one or more PARAMETER_NAME=VALUE specifications to control execution."
write " "
write "   In the last case:     LABEL-LIST INP=+B    "
write "LABEL-LIST was the program name,"
write "INP was the parameter name (specifically the input file name),"
write "+B was the parameter value to be used in this execution."
write " "
write ".................................................................."
write ".......................THE PIXEL DATA............................."
write ".................................................................."
write "    Most VICAR programs alter the pixel data of the file."
write "Use the program LIST to look at the pixel data of the file you"
write "just created.  Type  LIST INP=+B   ."
write " "
exec
write " "
write "    Of course, sometimes you may not want to see (or process) the entire"
write "image.  In this case, you should specify the area you wish to process"
write "by using the VICAR SIZE parameter.  This parameter is standard for"
write "almost all VICAR programs, and has the format:"
write " "
write "       SIZE=(starting_line,starting_sample,#lines,#samples)  "
write " "
write "    Try using the SIZE field to look at a portion of your file A."
write "Type  LIST INP=+A SIZE=(4,2,5,5) "
write " "
exec
write " "
write "    Now alter the pixel data of your file A with program F2"
write "by adding 50 to each value.  This will create a new file with "
write "different pixel values.  Type  F2 INP=+A OUT=+B FUNCTION=""IN1+50""  ."
write " "
exec
write " "
write "   Look at what has happened to the pixel data now in B. "
write "Type  LIST INP=+B SIZE=(4,2,5,5) "
write " "
exec
write " "
write "   We only looked at a portion of the file, but, yes, all the"
write "pixels were altered.  To verify this, leave off the SIZE field.  "
write "Type  LIST INP=+B ."
write " "
exec
write " "
write "    OK, the pixel data was changed, but what about the labels."
write "Look at the label of the new file B.  Type  LABEL-LIST INP=+B   ."
write " "
exec
write " "
write "    Notice that VICAR added an item to the label indicating what"
write "processing occurred, as well as when and by whom.  Because this "
write "is a system function, all processing steps are so documented and"
write "in a standard way."
write "    You probably noticed that we used the file B as an output "
write "file twice.  VICAR never creates new versions of an existing file."
write "It writes over the same version (perhaps updating the size) without"
write "updating the creation date and time.  Do a VICAR directory command"
if ($syschar(1) = "VAX_VMS")
write "to see the .Z* files you have created.  Type  DIR VTMP:[000000]*.Z*   ."
else
write "to see the files you have created.  Type  LS $VTMP  .  VTMP in Caps."
end-if
write " "
exec
write " "
write ".................................................................."
write ".......................DEFINING VICAR COMMANDS...................."
write ".................................................................."
write "    This DIR command may not have told you all you wanted to know.  You"
if ($syschar(1) = "VAX_VMS")
write "could do a DCL DIR VTMP:[000000]*.Z*, but you can also define a new"
write "command within VICAR to do the job.  The DEFCMD command will define"
write "strings to be commands.  Type:"
write "DEFCMD DIRX ""DCL DIR/SIZE=ALL/OWNER VTMP:[000000]*.Z*""     ."
else
write "could do a USH LS -L $VTMP, but you can also define a new command within"
write "VICAR to do the job.  The DEFCMD command will define strings to be "
write "commands.  Type  DEFCMD USHX ""USH LS -L $VTMP""   .  VTMP in Caps."
end-if
write " "
exec
write " "
if ($syschar(1) = "VAX_VMS")
write "Now try your new command DIRX.  Type  DIRX    ."
else
write "Now try your new command USHX.  Type  USHX    ."
end-if
write " "
exec
write " "
write ".................................................................."
write ".......................COMMAND QUALIFIERS........................."
write ".................................................................."
write "    Earlier in this session, you ran program GEN by restoring saved"
write "parameter values in TUTOR.  You can do the same thing from Command"
write "mode by using Command Qualifiers.  These qualifiers are independent"
write "of the command or program being invoked, they merely alter how the"
write "invocation is done.  Invoke GEN again with the same parameter values"
write "from a command line by typing  GEN |RESTORE=GEN| ."
write " " 
exec
write " "
write "    The RESTORE qualifier indicates that VICAR should be able to find"
write "the parameter values in a file called GEN.PAR saved from the "
write "TUTOR SAVE command."
write "    Another useful Command Qualifier will direct the output of an"
write "invoked command to a disk file that may be printed.  List out"
write "your GEN'd image to a file by typing  LIST |STDOUT=TEMP.LIS| INP=+A ."
write " "
exec
write " "
write "    Verify that the file TEMP.LIS contains the listing by typing"
if ($syschar(1) = "VAX_VMS")
write "DCL TYPE TEMP.LIS ."
else
write "USH CAT TEMP.LIS ."
end-if
write " "
exec
write " "
write ".................................................................."
write ".......................USING BATCH QUEUES........................."
write ".................................................................."
write "    Well, you're not going to do all your work on a terminal, so you"
write "need to know how to initiate a batch job.  The VICAR USER'S GUIDE"
write "tells how to set up the job stream files called procedures, which"
if ($syschar(1) = "VAX_VMS")
write "is the most common use of batch.  However, you can just execute"
write "one module in batch, which is what you will now do.  First, find"
write "out what the batch queues are called at your facility.  Do this"
write "by typing DCL SHOW QUE/BATCH ."
else
write "is the most common use of batch.  However, you can just execute"
write "one module in batch, which is what you will now do.  First determine"
write "if you have any batch jobs queued.  Do this by typing USH JOBS  ."
end-if
write " "
exec
write " "
if ($syschar(1) = "VAX_VMS")
write "    There may be more than one batch queue, so find the one in which"
write "jobs run immediately (probably called FAST or something like that)."
write "Use another Command Qualifier to submit a module to the batch queue."
write "Type  LABEL-LIST |RUNTYPE=(BATCH[,FAST])| INP=+A . Where [,FAST]"
write "indicates the fast queue when available.  Do not include the brackets."
else
write "You did not have any batch jobs queued.  Use another Command Qualifier"
write "to submit a module to the batch queue."
write "Type  LABEL-LIST |RUNTYPE=(BATCH)| INP=+A .  "
end-if
write " "
exec
write " "
write ".................................................................."
write ".......................LOG FILES.................................."
write ".................................................................."
write "    When the module is finished executing, the output will reside in"
if ($syschar(1) = "VAX_VMS")
write "a disk file called LABEL.LOG which may be listed.  Wait for the "
write "message indicating job completion and type DCL TYPE LABEL.LOG ."
else
write "a disk file called LABEL1.LOG which may be listed."
write "Type USH CAT LABEL1.LOG    or   USH CAT LABEL1.LOG.STDOUT  .  The "
write "LABEL1.LOG.STDOUT file is only the job results, while LABEL1.LOG"
write "is the log of the LABEL proc execution."
end-if
write " "
exec
write " "
write "    Job streams or procedures which contain lots of invocations and"
write "commands are completely analogous to what you just did.  They are"
write "submitted to a queue the same way and also result in a .LOG file."
write " "
write ".................................................................."
write ".....................FINISHING UP................................."
write ".................................................................."
write "    We are done with most of this tutorial session.  In order to print"
write "out the session log file, the logging function must be disabled. "
write "Type  DISABLE-LOG."
write " "
exec
write " "
if ($syschar(1) = "VAX_VMS")
write "    Now that the log file is free, print it on the local printer.  But"
write "first determine if the symbol P168 exists.  Type DCL SHOW SYM P168 ."
else
write "    Now that the log file is free, print it on the default printer.  But"
write "first determine the default printer exists.  Type USH LPSTAT -S  ."
end-if
write " "
exec
write " "
if ($syschar(1) = "VAX_VMS")
write "    If symbol P168 is defined, use it instead of PRINT.  Either way, "
write "type DCL P168 SESSION.LOG   or   DCL PRINT SESSION.LOG ."
else
write "    If the default printer is defined, type USH LP SESSION.LOG  ."
end-if
write " "
exec
write " "
write ".................................................................."
write ".......................VICAR MENU MODE............................"
write ".................................................................."
write "    You have tried out VICAR's Command mode and TUTOR mode.  There is"
write "one other mode to play with called MENU mode.  Before starting that"
write "up, remember that many details that this Tutorial session cannot"
write "instruct you on are explained in the VICAR USER'S GUIDE.  Every"
write "user should have one."
write "    The final act of this tutorial will be to turn you loose in the"
write "VICAR MENU mode.  A system-wide MENU has been set up to guide users"
write "to VICAR programs based upon the functionality required.  The "
write "MENU is rather self-explanatory, but recall that you can always"
write "ask for HELP."
write " "
write "Invoke the MENU mode by typing the command MENU.  Within the"
write "MENU utility, type any of the listed choices, except LOGOFF. End by"
write "typing EXIT. Now, type MENU and when done type EXIT."
write " "
write "Delete any files generated in your directory as a result of running NUT"
write " "
exec
return
end-proc
!procedure help=*
!end-proc
.title
NUT - New User Tutorial.
.help
PURPOSE

NUT provides a new VICAR user an interactive journey through the basic
capabilities of VICAR.
.PAGE
EXECUTION

  nut

OPERATION

NUT guides the new VICAR user by specifing keystrokes, providing prompts,
and rational for commands and actions that are in general use by VICAR users.

PROCESSING HISTORY:

Revisions:
  10/31/94  RNR(CRI) Made Portable for UNIX
.end
$ Return
$!#############################################################################
$Test_File:
$ create tstnut.pdf
procedure
refgbl $syschar
body
!  
write " " 
write  "This is a dummy test pdf, as NUT is only an interactive proc."
if ($syschar(1) = "VAX_VMS")
write  "To run NUT type NUT at the VICAR prompt."
else
write  "To run NUT type NUT at the VICAR prompt.  Use lower case."
end-if
end-proc
$ Return
$!#############################################################################
