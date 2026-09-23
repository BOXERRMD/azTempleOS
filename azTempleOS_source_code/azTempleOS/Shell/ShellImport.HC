/*
This file is include by $LK,"MakeHome.HC.Z",A="FI:/Home/MakeHome.HC.Z"$
It MUST be incude before including $LK,"HomeKeyPlugIns.HC.Z",A="FI:/Home/HomeKeyPlugIns.HC.Z"$
*/

#exe{Cd(__DIR__);};
#include "SearchPath"
#include "ShellHook"

#exe{Cd("~/");}; // return to /Home
