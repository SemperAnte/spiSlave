# 1. clean internal directories, remove all objects without specified extension
# 2. backup top directory to specified path

# path for backup, copy from "projects" to "projects"
# choose path that existing
set dirCloud [list "C:/Users/SemperAnte/Dropbox/projects"\
                   "C:/Users/SA/Dropbox/projects"]
# directories for cleaning
set dirSearch [list "sim" "quartus"]
# exclude extensions
set excExt [list "sv" "v" "vh" "vhd"\
                 "do" "tcl"\
                 "qpf" "qsf" "sdc" "qsys" "sopcinfo"]

# choose path for cloud that existing                 
foreach dir $dirCloud {
   if { [file exist $dir] } {
      set dirCloud $dir
      break
   }
}

# create empty list for objects need to removing
set objFullClean [list]
foreach dir $dirSearch {
   if { [file exist $dir] } {      
      # find all objects in directory
      set objDirClean [glob -nocomplain [file join $dir "*"]]
      # remove object with specified extension
      foreach ext $excExt {
         set objDirClean [lsearch -all -glob -inline -not $objDirClean "*.$ext"]
      }
      # if objects still exist
      if { [llength $objDirClean] > 0 } {
         lappend objFullClean {*}$objDirClean
         puts "This objects for directory \"$dir\" will be removed:"
         foreach obj $objDirClean {
            puts -nonewline "   [format %-70s $obj]"
            puts "- [file type $obj]"
         }
      } else {
         puts "Directory \"$dir\" is already clean"
      }      
   } else {
      puts "Directory \"$dir\" doesnt exist"
   }
}
# if isnt empty
if { [llength $objFullClean] > 0 } {
   # ask user
   puts "Remove this objects (y/n)? :"
   set answer [ gets stdin ]
   # check answer
   if { [string compare -nocase -length 1 $answer "y"] == 0 } {
      file delete -force {*}$objFullClean
      puts "Successfully clean"
   } else {
      puts "Cancel clean"
   } 
}

# source directory
set dirSource [pwd]
# find subpaths after key word "projects" 
set dirTarget [file split $dirSource]
set ind [lsearch -exact $dirTarget "projects"]
set dirTarget [lrange $dirTarget [incr ind] end] 
set dirTarget [file join $dirCloud {*}$dirTarget]
# puts action
set ind 1
puts ""
if { [file exist $dirTarget] } {
   puts "$ind. Removing directory $dirTarget"
   incr ind
}
puts "$ind. Copy directory from $dirSource to $dirTarget"
puts "Perform this actions? (y/n) :"
set answer [ gets stdin ]
# check answer
if { [string compare -nocase -length 1 $answer "y"] == 0 } {
   if { [file exist $dirTarget] } {
      file delete -force $dirTarget
   }
   file copy -force $dirSource $dirTarget
   puts "Successfully backup"
} else {
   puts "Cancel backup"
}