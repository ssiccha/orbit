#############################################################################
##
##                             parorb package
##  stack.gi
##                                                          Sergio Siccha
##
##  Copyright...
##
##  Implementation of MyStack
##
#############################################################################

###############################
# Operation StackCreate
# Input:
#   length -
# Filters:
#   IsInt
#
# Output:
#   stack;
###############################
InstallMethod( StackCreate, "Initialize empty stack of given length.",
[ IsInt ],
function( length )
  local stack;
  stack := rec( elements := [], last := 0 );
  stack.elements[ length+1 ] := fail; ## force allocation of storage
  Objectify( StackType, stack );
  return stack;
end );

###############################
# Operation StackPush
# Input:
#   obj -
# Filters:
#   IsObject
#
# Output:
#   none
###############################
InstallMethod( StackPush, "Push obj to stack.",
[ IsMyStack, IsObject ],
function( stack, obj )
  stack!.last := stack!.last + 1;
  stack!.elements[ stack!.last ] := obj;
end );

###############################
# Operation StackPop
# Input:
#   stack -
# Filters:
#   IsMyStack
#
# Output:
#   last element of stack
###############################
InstallMethod( StackPop, "Pop the last object that was added to stack",
[ IsMyStack ],
function( stack )
  stack!.last := stack!.last - 1;
  return stack!.elements[ stack!.last + 1 ];
end );

###############################
# Operation StackPopAll
# Input:
#   stack -
# Filters:
#   IsMyStack
#
# Output:
#   all elements of stack
###############################
InstallMethod( StackPopAll, "Pop all objects of stack.",
[ IsMyStack ],
function( stack )
  local last;
  stack!.last := 0;
  return stack!.elements{ [ 1 .. last ] };
end );


###############################
# Operation StackPeek
# Input:
#   stack -
# Filters:
#   IsMyStack
#
# Output:
#   last element of stack
###############################
InstallMethod( StackPeek, "Peek the last object that was added to stack",
[ IsMyStack ],
function( stack )
  return stack!.elements[ stack!.last ];
end );

###############################
# Operation StackIsEmpty
# Input:
#   stack -
# Filters:
#   IsMyStack
#
# Output:
#   stack!.last = 0;
###############################
InstallMethod( StackIsEmpty, "Checks whether stack is empty.",
[ IsMyStack ],
function( stack )
  return stack!.last = 0;
end );
