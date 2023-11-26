import gi
import subprocess, threading
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gio, GObject

class Main:
	def __init__(self):
		self.builder = Gtk.Builder()
		self.builder.add_from_file("test.glade")
		self.builder.connect_signals(self)
		self.window = self.builder.get_object("window")	
		self.window.set_default_size(565, 570)
		
		header_bar = Gtk.HeaderBar()
		header_bar.set_title("Filmux GUI")
		header_bar.set_show_close_button(True)
		self.window.set_titlebar(header_bar)
		header_bar.get_style_context().add_class("centered-header-bar")

		#=======Start of init for Cut Section=======#
		
		self.file_chooser = self.builder.get_object("file_chooser")
		self.folder_chooser = self.builder.get_object("output_folder_chooser")
		self.spinner_cut = self.builder.get_object("spinner_for_cut")

		self.scale_adjuster = self.builder.get_object("adjustment1")

		self.output_name_toggled = False
		self.selected_file = ""
		self.selected_folder = ""
		self.time_start = 0
		self.time_end = 0

		#=======End init for Cut Section=======#

		#=======Start of init for Join Section=======#

		self.join_file_chooser = self.builder.get_object("join_file_chooser")
		self.selected_file_join = ""

		#=======End of init for Join Section=======#
	
	#==========Start of functions for Cut Section==========#
	def run_async(self, sc_path, args):
		try:
			self.spinner_cut.start()
			threading.Thread(target=self.run_script, args=(sc_path, args)).start()
		except Exception as e:
			self.show_completion_dialogue(f"Error: Please give valid inputs: {e}")
	
	def run_script(self, sc_path, args):
		try:
			res = subprocess.run(args, check=True, capture_output=True, text=True)
			print(res.stdout)
			self.show_completion_dialogue("Video cut Completed")
		except subprocess.CalledProcessError as e:
			self.show_completion_dialogue(f"Error: Please give valid inputs: {e}")
		finally:
			self.spinner_cut.stop()

	def on_file_selected(self, widget):
		self.selected_file = self.file_chooser.get_filename()
		print(self.selected_file)
		
	def on_folder_changed(self, widget):
		self.selected_folder = self.folder_chooser.get_uri()
		self.file_path = Gio.File.new_for_uri(self.selected_folder).get_path()
		
	def on_start_time(self, entry):
		self.time_start = entry.get_text()
		
	def on_end_time(self, entry):
		self.time_end = entry.get_text()

	def on_output_name(self, entry):
		self.output_name = entry.get_text()
		if self.output_name:
			self.output_name_toggled = True
		else:
			self.output_name_toggled = False
		
	def cut_on_clicked(self, widget):
		try:
			bs_path = "/home/seetharaman/Videos/Filmux/fc.sh"
			if self.output_name_toggled:
				bc = [bs_path, self.selected_file, self.time_start, self.time_end, self.file_path, self.output_name]
				self.run_async("/bin/bash", bc)
			else:
				bc = [bs_path, self.selected_file, self.time_start, self.time_end, self.file_path]
				self.run_async("/bin/bash", bc)
		except Exception as e:
			self.show_completion_dialogue(f"Error: Please give valid inputs {e}")

	def cut_scale_changed(self, widget):
		self.cut_scale_value = self.scale_adjuster.get_value()
		print(self.cut_scale_value)

	#==========End of functions for Cut Section==========#


	#==========Start of functions for Join Section==========#

	def on_file_selected_join(self, widget):
		self.selected_file_join = widget.get_filenames()
		print(self.selected_file_join)

	#==========End of functions for Join Section==========#

	def show_completion_dialogue(self, message):
		dialog = Gtk.MessageDialog(
			parent=self.window,
			flags=0,
			message_type=Gtk.MessageType.INFO,
			buttons=Gtk.ButtonsType.OK,
			text=message
		)
		dialog.run()
		dialog.destroy()
	

if __name__ == "__main__":
	win = Main()
	win.window.connect("destroy", Gtk.main_quit)
	win.window.show_all()
	Gtk.main()



# Removed Lines
# Line 22 - self.cut_start_time = self.builder.get_object("cut_start_time")