!< VTK file class.
module vtk_fortran_vtk_file
!< VTK file class.
use befor64
use penf
use stringifor
use vtk_fortran_vtk_file_xml_writer_abstract
use vtk_fortran_vtk_file_xml_writer_appended
use vtk_fortran_vtk_file_xml_writer_ascii_local
use vtk_fortran_vtk_file_xml_writer_binary_local

implicit none
private
public :: vtk_file

type :: vtk_file
  !< VTK file class.
  private
  class(xml_writer_abstract), allocatable, public :: xml_writer !< XML writer.
  contains
    procedure, pass(self) :: get_xml_volatile !< Return the eventual XML volatile string file.
    procedure, pass(self) :: initialize       !< Initialize file.
    procedure, pass(self) :: finalize         !< Finalize file.
    procedure, pass(self) :: free             !< Free allocated memory.
endtype vtk_file
contains
   pure subroutine get_xml_volatile(self, xml_volatile, error)
   !< Return the eventual XML volatile string file.
   class(vtk_file),  intent(in)               :: self         !< VTK file.
   character(len=:), intent(out), allocatable :: xml_volatile !< XML volatile file.
   integer(I4P),     intent(out), optional    :: error !< Error status.

   call self%xml_writer%get_xml_volatile(xml_volatile=xml_volatile, error=error)
   endsubroutine get_xml_volatile

   function initialize(self, format, filename, mesh_topology, is_volatile, nx1, nx2, ny1, ny2, nz1, nz2) result(error)
   !< Initialize file (writer).
   !<
   !< @note This function must be the first to be called.
   !<
   !<### Supported output formats are (the passed specifier value is case insensitive):
   !<
   !<- ASCII: data are saved in ASCII format;
   !<- BINARY: data are saved in base64 encoded format;
   !<- RAW: data are saved in raw-binary format in the appended tag of the XML file;
   !<- BINARY-APPENDED: data are saved in base64 encoded format in the appended tag of the XML file.
   !<
   !<### Supported topologies are:
   !<
   !<- RectilinearGrid;
   !<- StructuredGrid;
   !<- UnstructuredGrid.
   !<
   !<### Example of usage
   !<
   !<```fortran
   !< type(vtk_file) :: vtk
   !< integer(I4P)   :: nx1, nx2, ny1, ny2, nz1, nz2
   !< ...
   !< error = vtk%initialize('BINARY','XML_RECT_BINARY.vtr','RectilinearGrid',nx1=nx1,nx2=nx2,ny1=ny1,ny2=ny2,nz1=nz1,nz2=nz2)
   !< ...
   !<```
   !< @note The file extension is necessary in the file name. The XML standard has different extensions for each
   !< different topologies (e.g. *vtr* for rectilinear topology). See the VTK-standard file for more information.
   class(vtk_file), intent(inout)        :: self          !< VTK file.
   character(*),    intent(in)           :: format        !< File format: ASCII, BINARY, RAW or BINARY-APPENDED.
   character(*),    intent(in)           :: filename      !< File name.
   character(*),    intent(in)           :: mesh_topology !< Mesh topology.
   logical,         intent(in), optional :: is_volatile   !< Flag to check volatile writer.
   integer(I4P),    intent(in), optional :: nx1           !< Initial node of x axis.
   integer(I4P),    intent(in), optional :: nx2           !< Final node of x axis.
   integer(I4P),    intent(in), optional :: ny1           !< Initial node of y axis.
   integer(I4P),    intent(in), optional :: ny2           !< Final node of y axis.
   integer(I4P),    intent(in), optional :: nz1           !< Initial node of z axis.
   integer(I4P),    intent(in), optional :: nz2           !< Final node of z axis.
   integer(I4P)                          :: error         !< Error status.
   type(string)                          :: fformat       !< File format.

   if (.not.is_initialized) call penf_init
   if (.not.is_b64_initialized) call b64_init
   fformat = trim(adjustl(format))
   fformat = fformat%upper()
   if (allocated(self%xml_writer)) deallocate(self%xml_writer)
   select case(fformat%chars())
   case('ASCII')
      allocate(xml_writer_ascii_local :: self%xml_writer)
   case('BINARY-APPENDED', 'RAW')
      allocate(xml_writer_appended :: self%xml_writer)
   case('BINARY')
      allocate(xml_writer_binary_local :: self%xml_writer)
   case default
      error = 1
   endselect
   error = self%xml_writer%initialize(format=format, filename=filename, mesh_topology=mesh_topology, &
                                      is_volatile=is_volatile,                                       &
                                      nx1=nx1, nx2=nx2, ny1=ny1, ny2=ny2, nz1=nz1, nz2=nz2)
   endfunction initialize

   function finalize(self) result(error)
   !< Finalize file (writer).
   class(vtk_file), intent(inout)  :: self  !< VTK file.
   integer(I4P)                    :: error !< Error status.
   character(len=:),           allocatable :: xml_volatile !< XML volatile file.

   error = 1
   if (allocated(self%xml_writer)) error = self%xml_writer%finalize()
   endfunction finalize

   elemental subroutine free(self, error)
   !< Free allocated memory.
   class(vtk_file), intent(inout)         :: self  !< VTK file.
   integer(I4P),    intent(out), optional :: error !< Error status.

   if (allocated(self%xml_writer)) call self%xml_writer%free(error=error)
   endsubroutine free
endmodule vtk_fortran_vtk_file
