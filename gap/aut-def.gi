#############################################################################
##
#W  aut-def.gi                         Manuel Delgado <mdelgado@fc.up.pt>
#W                                     Jose Morais    <jjoao@netcabo.pt>
##
##
#H  @(#)$Id: aut-def.gi,v 1.05 $
##
#Y  Copyright (C)  2004,  CMUP, Universidade do Porto, Portugal
##
#############################################################################
##
##  This file contains some generic methods for automata. 
##
#############################################################################
##
##
## Example
## gap> A:=Automaton("det",4,2,[[3,3,3,4],[3,4,3,4]],[1],[4]);
## < deterministic automaton on 2 letters with 4 states >
## gap> Display(A);
##    |  1  2  3  4
## -----------------
##  a |  3  3  3  4
##  b |  3  4  3  4
## Initial state:   [ 1 ]
## Accepting state: [ 4 ]
##
## The first component of a non deterministic automaton is <"nondet">
## and that of an epsilon automaton is <"epsilon">.
##
## In the case of automata with e-transitions, the last line of the 
## transition table corresponds to the e-transitions (i.e., epsilon is 
## considered the last letter of the alphabet).

#############################################################################
##
#R  
## The transitions of a deterministic automaton are always represented by 
## a matrix that may be dense or 
## not. If it is dense, the automaton is dense deterministic.
## The holes in the list may be replaced by zeros.
##
## The nondeterministic automata may be represented the same way, with
## sets of states instead of states in the transition matrix.
##
## In order to use this representation for epsilon-automata, an extra letter 
## must be added to the alphabet.
##

############################################################################
DeclareRepresentation( "IsAutomatonRep", IsComponentObjectRep, 
        ["type","states","alphabet","transitions","initial","accepting"]);

######################################################################
##
#F  Automaton(Type, Size, SizeAlphabet,TransitionTable, ListInitial, 
##  ListAccepting )
##
##  Produces an automaton
##
InstallGlobalFunction( Automaton, function(Type, Size, SizeAlphabet, 
        TransitionTable, ListInitial, ListAccepting )
        
        local A, aut, F, i, j, x, y, TT, l;
    
    #some tests...
    if not IsPosInt(Size) then
        Error("The size of the automaton must be a positive integer");
    elif not (IsPosInt(SizeAlphabet) or IsString(SizeAlphabet)) then
        Error("The size of the alphabet must be a positive integer or a string");
    fi;
    
    # Construct the family of all automata.
    F:= NewFamily( "Automata" ,
                IsAutomatonObj );
    if IsPosInt(SizeAlphabet) then
        F!.alphabet := SizeAlphabet;
    else
        if Type = "epsilon" then
            if not SizeAlphabet[Length(SizeAlphabet)] = '@' then
                Error("The last letter of the alphabet must be @");
            fi;
            j:=0;
            for i in SizeAlphabet do
                if i = '@' then
                    j := j + 1;
                fi;
            od;
            if j > 1 then
                Error("The alphabet must contain only one @");
            fi;
        fi;
        F!.alphabet := SizeAlphabet;
        SizeAlphabet := Length(F!.alphabet);
    fi;
    
    if not IsList(TransitionTable) then
        Error("The transition table must be given as a matrix");
    elif not IsList(ListInitial) then
        Error("The initial states must be provided as a list");
    elif not IsList(ListAccepting) then
        Error("The accepting states must be provided as a list");
    elif (Length(TransitionTable) <> SizeAlphabet) then
        Error("The number of rows of the transition table matrix must equal the size of the alphabet");
    fi;
    
    #The type of the automaton: deterministic or not must be given
    if Type <> "det" and Type <> "nondet" and Type <> "epsilon" then
        Error( "Please specify the type of the automaton as \"det\" or \"nondet\" or \"epsilon\"");
    fi;
    
    
    # Fill the holes in the transition table with <0> in the case of 
    # deterministic automata and with <[0]> in the case of non 
    # deterministic automata
    TT := NullMat(SizeAlphabet,Size);
    for i in [1 .. SizeAlphabet] do
        for j in[1 .. Size] do
            if Type = "det" then
                if IsBound(TransitionTable[i][j]) then
                    if IsInt(TransitionTable[i][j]) then
                        if TransitionTable[i][j] > Size or TransitionTable[i][j] < 0 then
                            Error(Concatenation("TransitionTable[", String(i), "][", String(j), "] must be in [0 .. ", String(Size), "]"));
                        else
                            TT[i][j] := TransitionTable[i][j];
                        fi;
                    else
                        Error(Concatenation("TransitionTable[", String(i), "][", String(j), "] must be an integer"));
                    fi;
                else
                    TT[i][j] := 0;
                fi;
            else
                if IsBound(TransitionTable[i][j]) then 
                    if IsInt(TransitionTable[i][j]) then
                        if TransitionTable[i][j] > Size or TransitionTable[i][j] < 0 then
                            Error(Concatenation("TransitionTable[", String(i), "][", String(j), "] must be in [0 .. ", String(Size), "]"));
                        else
                            if TransitionTable[i][j] = 0 then
                                TT[i][j] := [];
                            else
                                TT[i][j] := [TransitionTable[i][j]];
                            fi;
                        fi;
                    elif IsRowVector(TransitionTable[i][j]) then
                        for y in [1 .. Length(TransitionTable[i][j])] do
                            if not IsBound(TransitionTable[i][j][y]) then
                                Error(Concatenation("TransitionTable[", String(i), "][", String(j), "] must have all elements in [1 .. ", String(Size), "]"));
                            elif IsPosInt(TransitionTable[i][j][y]) then
                                x := TransitionTable[i][j][y];
                                if x > Size or x < 0 then
                                    Error(Concatenation("TransitionTable[", String(i), "][", String(j), "] must have all elements in [1 .. ", String(Size), "]"));
                                fi;
                            elif TransitionTable[i][j][y] = 0 then
                                Unbind(TransitionTable[i][j][y]);
                            else
                                Error(Concatenation("TransitionTable[", String(i), "][", String(j), "] must have all elements in [1 .. ", String(Size), "]"));
                            fi;
                        od;
                        TT[i][j] := TransitionTable[i][j];
                    elif not TransitionTable[i][j] = [] then
                        Error(Concatenation("TransitionTable[", String(i), "][", String(j), "] must be in [0 .. ", String(Size), "]"));
                    else
                        TT[i][j] := TransitionTable[i][j];
                    fi;
                else
                    TT[i][j] := [];
                fi;
            fi;
        od;
    od;
    
    aut := rec(type := Type,
               alphabet := SizeAlphabet,
               states := Size,
               initial := ListInitial,
               accepting := ListAccepting,
               transitions := TT );
    
    A := Objectify( NewType( F, IsAutomatonObj and 
                 IsAutomatonRep and IsAttributeStoringRep ),
                 aut );
    
    # Return the automaton.
    return A;
end);


#############################################################################
##
#M  ViewObj( <A> ) . . . . . . . . . . . print automata
##
InstallMethod( ViewObj,
    "displays an automaton",
    true,
    [IsAutomatonObj and IsAutomatonRep], 0,
function( A )
    if A!.type = "det" then
        Print("< deterministic automaton on ", A!.alphabet, " letters with ", A!.states, " states >");
    elif A!.type = "nondet" then
        Print("< non deterministic automaton on ", A!.alphabet, " letters with ", A!.states, " states >");
    else
        Print("< epsilon automaton on ", A!.alphabet, " letters with ", A!.states, " states >");
    fi;
end);


#############################################################################
##
#M  PrintObj( <A> ) . . . . . . . . . . . print automata
##
InstallMethod( PrintObj,
    "displays an automaton",
    true,
    [IsAutomatonObj and IsAutomatonRep], 0,
function( A )
    Print(String(A),"\n");
end);

#############################################################################
##
#M  Display( <A> ) . . . . . . . . . . . print automata
##
InstallMethod( Display,
    "displays an automaton",
    true,
    [IsAutomatonObj and IsAutomatonRep], 0,
function( A )
    local a, i, j, q, str, letters, sizea, sizeq, lsizeq, len;
    
    if IsPosInt(FamilyObj(A)!.alphabet) then
        letters := ["a","b","c","d","e","f","g"];
    else
        letters := [];
        for i in FamilyObj(A)!.alphabet do
            Add(letters, [i]);
        od;
    fi;
    if A!.states < 10 then
        if A!.type = "det" then
            if A!.alphabet < 8 then
                str := "   |  ";
                for i in [1 .. A!.states] do
                    str := Concatenation(str, String(i), "  ");
                od;
                str := Concatenation(str, "\n-----");
                for i in [1 .. A!.states] do
                    str := Concatenation(str, "---");
                od;
                str := Concatenation(str, "\n");
                for a in [1 .. A!.alphabet] do
                    str := Concatenation(str, " ", letters[a], " |  ");
                    for i in [1 .. A!.states] do
                        q := A!.transitions[a][i];
                        if q = 0 then
                            str := Concatenation(str, "   ");
                        else
                            str := Concatenation(str, String(q),"  ");
                        fi;
                    od;
                    str := Concatenation(str, "\n");
                od;
                if IsBound(A!.accepting[2]) then
                    str := Concatenation(str, "Initial state:    ", String(A!.initial), "\n");
                    str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                else
                    str := Concatenation(str, "Initial state:   ", String(A!.initial), "\n");
                    str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                fi;
            else
                sizea := Length(String(A!.alphabet));
                str := "   ";
                for i in [1 .. sizea] do
                    str := Concatenation(str, " ");
                od;
                str := Concatenation(str, "|  ");
                for i in [1 .. A!.states] do
                    str := Concatenation(str, String(i), "  ");
                od;
                str := Concatenation(str, "\n----");
                for i in [1 .. sizea] do
                    str := Concatenation(str, "-");
                od;
                for i in [1 .. A!.states] do
                    str := Concatenation(str, "---");
                od;
                str := Concatenation(str, "-\n");
                for a in [1 .. A!.alphabet] do
                    str := Concatenation(str, " a", String(a));
                    for i in [Length(String(a)) .. sizea] do
                        str := Concatenation(str, " ");
                    od;
                    str := Concatenation(str, "|  ");
                    for i in [1 .. A!.states] do
                        q := A!.transitions[a][i];
                        if q = 0 then
                            str := Concatenation(str, "   ");
                        else
                            str := Concatenation(str, String(q),"  ");
                        fi;
                    od;
                    str := Concatenation(str, "\n");
                od;
                if IsBound(A!.accepting[2]) then
                    str := Concatenation(str, "Initial state:    ", String(A!.initial), "\n");
                    str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                elif A!.accepting = [] then
                    str := Concatenation(str, "Initial state:   ", String(A!.initial), "\n");
                else
                    str := Concatenation(str, "Initial state:   ", String(A!.initial), "\n");
                    str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                fi;
            fi;
        elif A!.type = "nondet" then
            lsizeq := [];
            for i in [1 .. A!.states] do
                sizeq := 0;
                for a in [1 .. A!.alphabet] do
                    len := Length(A!.transitions[a][i]);
                    if len > sizeq then
                        sizeq := len;
                    fi;
                od;
                sizeq := sizeq + 2*(sizeq-1) + 4;
                lsizeq[i] := sizeq;
            od;
            if A!.alphabet < 8 then
                str := "   |  ";
                for i in [1 .. A!.states-1] do
                    str := Concatenation(str, String(i), "  ");
                    for j in [1 .. lsizeq[i]] do
                        str := Concatenation(str, " ");
                    od;
                od;
                str := Concatenation(str, String(A!.states), "\n---");
                for i in [1 .. A!.states] do
                    str := Concatenation(str, "---");
                    for j in [1 .. lsizeq[i]] do
                        str := Concatenation(str, "-");
                    od;
                od;
                str := Concatenation(str, "\n");
                for a in [1 .. A!.alphabet] do
                    str := Concatenation(str, " ", letters[a], " | ");
                    for i in [1 .. A!.states] do
                        q := A!.transitions[a][i];
                        
                        if q = [] then
                            str := Concatenation(str, "   ");
                            for j in [1 .. lsizeq[i]] do
                                str := Concatenation(str, " ");
                            od;
                        else
                            str := Concatenation(str, String(q),"  ");
                            len := Length(q);
                            len := len + 2*(len-1) + 4;
                            for j in [len .. lsizeq[i]] do
                                str := Concatenation(str, " ");
                            od;
                        fi;
                    od;
                    str := Concatenation(str, "\n");
                od;
                if IsBound(A!.initial[2]) then
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial states:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    elif A!.accepting = [] then
                        str := Concatenation(str, "Initial states:  ", String(A!.initial), "\n");
                    else
                        str := Concatenation(str, "Initial states:  ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                elif A!.initial = [] then
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    elif A!.accepting = [] then
                    else
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                else
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial state:    ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    elif A!.accepting = [] then
                        str := Concatenation(str, "Initial state:    ", String(A!.initial), "\n");
                    else
                        str := Concatenation(str, "Initial state:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                fi;
            else
                sizea := Length(String(A!.alphabet));
                str := "   ";
                for i in [1 .. sizea] do
                    str := Concatenation(str, " ");
                od;
                str := Concatenation(str, "|  ");
                for i in [1 .. A!.states-1] do
                    str := Concatenation(str, String(i), "  ");
                    for j in [1 .. lsizeq[i]] do
                        str := Concatenation(str, " ");
                    od;
                od;
                str := Concatenation(str,String(A!.states),  "\n---");
                for i in [1 .. sizea] do
                    str := Concatenation(str, "-");
                od;
                for i in [1 .. A!.states] do
                    str := Concatenation(str, "---");
                    for j in [1 .. lsizeq[i]] do
                        str := Concatenation(str, "-");
                    od;
                od;
                str := Concatenation(str, "\n");
                for a in [1 .. A!.alphabet] do
                    str := Concatenation(str, " a", String(a));
                    for i in [Length(String(a)) .. sizea] do
                        str := Concatenation(str, " ");
                    od;
                    str := Concatenation(str, "| ");
                    for i in [1 .. A!.states] do
                        q := A!.transitions[a][i];
                        if q = [] then
                            str := Concatenation(str, "   ");
                            for j in [1 .. lsizeq[i]] do
                                str := Concatenation(str, " ");
                            od;
                        else
                            str := Concatenation(str, String(q),"  ");
                            len := Length(q);
                            len := len + 2*(len-1) + 4;
                            for j in [len .. lsizeq[i]] do
                                str := Concatenation(str, " ");
                            od;
                        fi;
                    od;
                    str := Concatenation(str, "\n");
                od;
                if IsBound(A!.initial[2]) then
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial states:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    elif A!.accepting = [] then
                        str := Concatenation(str, "Initial states:  ", String(A!.initial), "\n");
                    else
                        str := Concatenation(str, "Initial states:  ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                elif A!.initial = [] then
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    elif A!.accepting = [] then
                    else
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                else
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial state:    ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    elif A!.accepting = [] then
                        str := Concatenation(str, "Initial state:    ", String(A!.initial), "\n");
                    else
                        str := Concatenation(str, "Initial state:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                fi;
            fi;
        else
            lsizeq := [];
            for i in [1 .. A!.states] do
                sizeq := 0;
                for a in [1 .. A!.alphabet] do
                    len := Length(A!.transitions[a][i]);
                    if len > sizeq then
                        sizeq := len;
                    fi;
                od;
                sizeq := sizeq + 2*(sizeq-1) + 4;
                lsizeq[i] := sizeq;
            od;
            if A!.alphabet < 8 then
                str := "   |  ";
                for i in [1 .. A!.states-1] do
                    str := Concatenation(str, String(i), "  ");
                    for j in [1 .. lsizeq[i]] do
                        str := Concatenation(str, " ");
                    od;
                od;
                str := Concatenation(str, String(A!.states), "\n---");
                for i in [1 .. A!.states] do
                    str := Concatenation(str, "---");
                    for j in [1 .. lsizeq[i]] do
                        str := Concatenation(str, "-");
                    od;
                od;
                str := Concatenation(str, "\n");
                for a in [1 .. A!.alphabet-1] do
                    str := Concatenation(str, " ", letters[a], " | ");
                    for i in [1 .. A!.states] do
                        q := A!.transitions[a][i];
                        
                        if q = [] then
                            str := Concatenation(str, "   ");
                            for j in [1 .. lsizeq[i]] do
                                str := Concatenation(str, " ");
                            od;
                        else
                            str := Concatenation(str, String(q),"  ");
                            len := Length(q);
                            len := len + 2*(len-1) + 4;
                            for j in [len .. lsizeq[i]] do
                                str := Concatenation(str, " ");
                            od;
                        fi;
                    od;
                    str := Concatenation(str, "\n");
                od;
                a := A!.alphabet;
                str := Concatenation(str, " @ | ");
                for i in [1 .. A!.states] do
                    q := A!.transitions[a][i];
                    if q = [] then
                        str := Concatenation(str, "   ");
                        for j in [1 .. lsizeq[i]] do
                            str := Concatenation(str, " ");
                        od;
                    else
                        str := Concatenation(str, String(q),"  ");
                        len := Length(q);
                        len := len + 2*(len-1) + 4;
                        for j in [len .. lsizeq[i]] do
                            str := Concatenation(str, " ");
                        od;
                    fi;
                od;
                str := Concatenation(str, "\n");
                if IsBound(A!.initial[2]) then
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial states:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    else
                        str := Concatenation(str, "Initial states:  ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                else
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial state:    ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    else
                        str := Concatenation(str, "Initial state:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                fi;
            else
                sizea := 6;
                str := "   ";
                for i in [1 .. sizea] do
                    str := Concatenation(str, " ");
                od;
                str := Concatenation(str, "|  ");
                for i in [1 .. A!.states-1] do
                    str := Concatenation(str, String(i), "  ");
                    for j in [1 .. lsizeq[i]] do
                        str := Concatenation(str, " ");
                    od;
                od;
                str := Concatenation(str,String(A!.states),  "\n---");
                for i in [1 .. sizea] do
                    str := Concatenation(str, "-");
                od;
                for i in [1 .. A!.states] do
                    str := Concatenation(str, "---");
                    for j in [1 .. lsizeq[i]] do
                        str := Concatenation(str, "-");
                    od;
                od;
                str := Concatenation(str, "\n");
                for a in [1 .. A!.alphabet-1] do
                    str := Concatenation(str, " a", String(a));
                    for i in [Length(String(a)) .. sizea] do
                        str := Concatenation(str, " ");
                    od;
                    str := Concatenation(str, "| ");
                    for i in [1 .. A!.states] do
                        q := A!.transitions[a][i];
                        if q = [] then
                            str := Concatenation(str, "   ");
                            for j in [1 .. lsizeq[i]] do
                                str := Concatenation(str, " ");
                            od;
                        else
                            str := Concatenation(str, String(q),"  ");
                            len := Length(q);
                            len := len + 2*(len-1) + 4;
                            for j in [len .. lsizeq[i]] do
                                str := Concatenation(str, " ");
                            od;
                        fi;
                    od;
                    str := Concatenation(str, "\n");
                od;
                a := A!.alphabet;
                str := Concatenation(str, " epsilon ");
                str := Concatenation(str, "| ");
                for i in [1 .. A!.states] do
                    q := A!.transitions[a][i];
                    if q = [] then
                        str := Concatenation(str, "   ");
                        for j in [1 .. lsizeq[i]] do
                            str := Concatenation(str, " ");
                        od;
                    else
                        str := Concatenation(str, String(q),"  ");
                        len := Length(q);
                        len := len + 2*(len-1) + 4;
                        for j in [len .. lsizeq[i]] do
                            str := Concatenation(str, " ");
                        od;
                    fi;
                od;
                str := Concatenation(str, "\n");
                if IsBound(A!.initial[2]) then
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial states:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    else
                        str := Concatenation(str, "Initial states:  ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                else
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial state:    ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    else
                        str := Concatenation(str, "Initial state:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                fi;
            fi;
        fi;
    else
        sizeq := Length(String(A!.states));
        if A!.type = "det" then
            if A!.alphabet < 8 then
                str := "";
                for i in [1 .. A!.states] do
                    for a in [1 .. A!.alphabet] do
                        q := A!.transitions[a][i];
                        if q > 0 then
                            str := Concatenation(str, String(i));
                            for j in [Length(String(i)) .. sizeq] do
                                str := Concatenation(str, " ");
                            od;
                            str := Concatenation(str, "  ", letters[a], "   ", String(q), "\n");
                        fi;
                    od;
                od;
                if IsBound(A!.accepting[2]) then
                    str := Concatenation(str, "Initial state:    ", String(A!.initial), "\n");
                    str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                else
                    str := Concatenation(str, "Initial state:   ", String(A!.initial), "\n");
                    str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                fi;
            else
                str := "";
                sizea := Length(String(A!.alphabet));
                for i in [1 .. A!.states] do
                    for a in [1 .. A!.alphabet] do
                        q := A!.transitions[a][i];
                        if q > 0 then
                            str := Concatenation(str, String(i));
                            for j in [Length(String(i)) .. sizeq] do
                                str := Concatenation(str, " ");
                            od;
                            str := Concatenation(str, "  a", String(a));
                            for j in [Length(String(a)) .. sizea] do
                                str := Concatenation(str, " ");
                            od;
                            str := Concatenation(str, "  ", String(q), "\n");
                        fi;
                    od;
                od;
                if IsBound(A!.accepting[2]) then
                    str := Concatenation(str, "Initial state:    ", String(A!.initial), "\n");
                    str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                else
                    str := Concatenation(str, "Initial state:   ", String(A!.initial), "\n");
                    str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                fi;
            fi;
        elif A!.type = "nondet" then
            if A!.alphabet < 8 then
                str := "";
                for i in [1 .. A!.states] do
                    for a in [1 .. A!.alphabet] do
                        q := A!.transitions[a][i];
                        if IsBound(q[1]) then
                            str := Concatenation(str, String(i));
                            for j in [Length(String(i)) .. sizeq] do
                                str := Concatenation(str, " ");
                            od;
                            str := Concatenation(str, "  ", letters[a], "   ", String(q), "\n");
                        fi;
                    od;
                od;
                if IsBound(A!.initial[2]) then
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial states:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    else
                        str := Concatenation(str, "Initial states:  ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                else
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial state:    ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    else
                        str := Concatenation(str, "Initial state:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                fi;
            else
                str := "";
                sizea := Length(String(A!.alphabet));
                for i in [1 .. A!.states] do
                    for a in [1 .. A!.alphabet] do
                        q := A!.transitions[a][i];
                        if IsBound(q[1]) then
                            str := Concatenation(str, String(i));
                            for j in [Length(String(i)) .. sizeq] do
                                str := Concatenation(str, " ");
                            od;
                            str := Concatenation(str, "  a", String(a));
                            for j in [Length(String(a)) .. sizea] do
                                str := Concatenation(str, " ");
                            od;
                            str := Concatenation(str, "  ", String(q), "\n");
                        fi;
                    od;
                od;
                if IsBound(A!.initial[2]) then
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial states:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    else
                        str := Concatenation(str, "Initial states:  ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                else
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial state:    ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    else
                        str := Concatenation(str, "Initial state:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                fi;
            fi;
        else
            if A!.alphabet < 8 then
                str := "";
                for i in [1 .. A!.states] do
                    for a in [1 .. A!.alphabet-1] do
                        q := A!.transitions[a][i];
                        if IsBound(q[1]) then
                            str := Concatenation(str, String(i));
                            for j in [Length(String(i)) .. sizeq] do
                                str := Concatenation(str, " ");
                            od;
                            str := Concatenation(str, "  ", letters[a], "         ", String(q), "\n");
                        fi;
                    od;
                    a := A!.alphabet;
                    q := A!.transitions[a][i];
                    if IsBound(q[1]) then
                        str := Concatenation(str, String(i));
                        for j in [Length(String(i)) .. sizeq] do
                            str := Concatenation(str, " ");
                        od;
                        str := Concatenation(str, "  epsilon   ", String(q), "\n");
                    fi;
                od;
                if IsBound(A!.initial[2]) then
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial states:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    else
                        str := Concatenation(str, "Initial states:  ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                else
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial state:    ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    else
                        str := Concatenation(str, "Initial state:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                fi;
            else
                str := "";
                sizea := 6;
                for i in [1 .. A!.states] do
                    for a in [1 .. A!.alphabet-1] do
                        q := A!.transitions[a][i];
                        if IsBound(q[1]) then
                            str := Concatenation(str, String(i));
                            for j in [Length(String(i)) .. sizeq] do
                                str := Concatenation(str, " ");
                            od;
                            str := Concatenation(str, "  a", String(a));
                            for j in [Length(String(a)) .. sizea] do
                                str := Concatenation(str, " ");
                            od;
                            str := Concatenation(str, "  ", String(q), "\n");
                        fi;
                    od;
                    a := A!.alphabet;
                    q := A!.transitions[a][i];
                    if IsBound(q[1]) then
                        str := Concatenation(str, String(i));
                        for j in [Length(String(i)) .. sizeq] do
                            str := Concatenation(str, " ");
                        od;
                        str := Concatenation(str, "  epsilon ");
                        str := Concatenation(str, "  ", String(q), "\n");
                    fi;
                od;
                if IsBound(A!.initial[2]) then
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial states:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    else
                        str := Concatenation(str, "Initial states:  ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                else
                    if IsBound(A!.accepting[2]) then
                        str := Concatenation(str, "Initial state:    ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting states: ", String(A!.accepting), "\n");
                    else
                        str := Concatenation(str, "Initial state:   ", String(A!.initial), "\n");
                        str := Concatenation(str, "Accepting state: ", String(A!.accepting), "\n");
                    fi;
                fi;
            fi;
        fi;
    fi;
    Print(str);    
end);

#############################################################################
##
#F  IsAutomaton(A)
##
##  Tests if A is an automaton
##
InstallGlobalFunction( IsAutomaton, function(A)
    return(IsAutomatonObj(A));
end);

#############################################################################
##
#F  RandomAutomaton(T, Q, A)
##
##  Given the type T, number of states Q and number of the input alphabet
##  symbols A, this function returns a pseudo random automaton with those
##  parameters.
##
InstallGlobalFunction(RandomAutomaton, function(T, Q, A)
    local i, transitions, a;
    
    if not IsPosInt(Q) then
        Error("The number of states must be a positive integer");
    fi;
    if not (IsPosInt(A) or IsString(A)) then
        Error("The number of symbols of the input alphabet must be a positive integer or a string");
    fi;
    
    if IsPosInt(A) then
        a := A;
    else
        a := SSortedList(A);
        A := Length(a);
    fi;
        
    if T = "det" then
        transitions := [];
        for i in [1 .. A] do
            transitions[i] := SSortedList(List([1 .. Q], i -> Random([0 .. Q])));
        od;
        return(Automaton(T, Q, a, transitions, [Random([1 .. Q])], SSortedList(List([1 .. Q], j -> Random([1 .. Q])))));
    elif T = "nondet" then
        transitions := [];
        for i in [1 .. A] do
            transitions[i] := List([1 .. Q], i -> SSortedList(List([1 .. Random([0 .. Q])], j -> Random([1 .. Q]))));
        od;
        return(Automaton(T, Q, a, transitions, SSortedList(List([1 .. Random([1 .. Q])], j -> Random([1 .. Q]))), SSortedList(List([1 .. Q], j -> Random([1 .. Q])))));
    else
        transitions := [];
        for i in [1 .. A+1] do
            transitions[i] := List([1 .. Q], i -> SSortedList(List([1 .. Random([0 .. Q])], j -> Random([1 .. Q]))));
        od;
        if IsInt(a) then
            return(Automaton(T, Q, a+1, transitions, SSortedList(List([1 .. Random([1 .. Q])], j -> Random([1 .. Q]))), SSortedList(List([1 .. Q], j -> Random([1 .. Q])))));
        else
            if not jascii[Length(jascii)] in a then
                return(Automaton(T, Q, Concatenation(a, [jascii[Length(jascii)]]), transitions, SSortedList(List([1 .. Random([1 .. Q])], j -> Random([1 .. Q]))), SSortedList(List([1 .. Q], j -> Random([1 .. Q])))));
            fi;
            Error("Please choose an alphabet, without the last character of the global variable 'jascii'");
        fi;
    fi;
end);


#############################################################################
##
#M  String( <A> ) . . . . . . . . . . . outputs the definition of an automaton as a string
##
InstallMethod( String,
    "Automaton to string",
    true,
    [IsAutomatonObj and IsAutomatonRep], 0,
function( A )
    local s;
    if IsPosInt(FamilyObj(A)!.alphabet) then
        s:=Concatenation("Automaton(\"", String(A!.type), "\",", String(A!.states), ",", String(A!.alphabet), ",", String(A!.transitions), ",", String(A!.initial), ",", String(A!.accepting), ");;");
    else
            if A!.type = "epsilon" then
                s:=Concatenation("x:=Automaton(\"", String(A!.type), "\",", String(A!.states), ",\"", Concatenation(FamilyObj(A)!.alphabet, "@"), "\",", String(A!.transitions), ",", String(A!.initial), ",", String(A!.accepting), ");;");
                           else
        s:=Concatenation("x:=Automaton(\"", String(A!.type), "\",", String(A!.states), ",\"", FamilyObj(A)!.alphabet, "\",", String(A!.transitions), ",", String(A!.initial), ",", String(A!.accepting), ");;");
                   fi;
    fi;
    return(s);
end);


############################################################################
##
#M Methods for the comparison operations for automata. 
##
InstallMethod( \=,
    "for two automata",
#    IsIdenticalObj,
        [ IsAutomatonObj and IsAutomatonRep, 
          IsAutomatonObj and IsAutomatonRep,  ], 
    0,
    function( x, y ) 
    return(String(x) = String(y));
      
      end );

InstallMethod( \<,
    "for two automata",
#    IsIdenticalObj,
        [ IsAutomatonObj and IsAutomatonRep, 
          IsAutomatonObj and IsAutomatonRep,  ], 
    0,
    function( x, y ) 
    return(String(x) < String(y)); 
end );



#E
##
