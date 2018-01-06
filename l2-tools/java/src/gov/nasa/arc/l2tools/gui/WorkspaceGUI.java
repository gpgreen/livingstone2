//
// * See the file "l2-tools/disclaimers-and-notices.txt" for 
// * information on usage and redistribution of this file, 
// * and for a DISCLAIMER OF ALL WARRANTIES.
//
package gov.nasa.arc.l2tools.gui;

import gov.nasa.arc.l2tools.swing.Menu;
import gov.nasa.arc.l2tools.swing.MenuItem;
import gov.nasa.arc.l2tools.swing.Button;
import gov.nasa.arc.l2tools.swing.AbstractAction;
import javax.swing.ImageIcon;
import javax.swing.KeyStroke;
import java.awt.Event;
import java.awt.event.KeyEvent;
/**
 * Creation date: (10/19/2000 3:54:39 PM)
 * @author: Andrew Bachmann
 */
public class WorkspaceGUI extends GUI {
	private gov.nasa.arc.l2tools.Workspace fieldWorkspace = null;
	private class MenuBar extends gov.nasa.arc.l2tools.swing.MenuBar {
		public MenuBar() {
			super();
			setName("MenuBar");
			createFileMenu();
			createEditMenu();
			createWindowMenu();
			createHelpMenu();
		}
		public void createFileMenu() {
			// create it
			Menu menu = new Menu("File");
			menu.setMnemonic('F');
			add(menu);
			// New Project
			MenuItem fileNew=menu.add(actions.fileNew);
			fileNew.setMnemonic(KeyEvent.VK_N);
			fileNew.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_N,Event.CTRL_MASK));
			// Open Project
			MenuItem fileOpen=menu.add(actions.fileOpen);
			fileOpen.setMnemonic(KeyEvent.VK_O);
			fileOpen.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_O,Event.CTRL_MASK));
			// Close Project
			MenuItem fileClose=menu.add(actions.fileClose);
			fileClose.setMnemonic(KeyEvent.VK_C);
			fileClose.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_W,Event.CTRL_MASK));
			////
			menu.addSeparator();
			// Save Project
			MenuItem fileSave=menu.add(actions.fileSave);
			fileSave.setMnemonic(KeyEvent.VK_S);
			fileSave.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_S,Event.CTRL_MASK));
			// Save As... Project
			MenuItem fileSaveAs=menu.add(actions.fileSaveAs);
			fileSaveAs.setMnemonic(KeyEvent.VK_A);
			////
			menu.addSeparator();
			// Page Setup
			MenuItem filePageSetup=menu.add(actions.filePageSetup);
			filePageSetup.setMnemonic(KeyEvent.VK_U);
			// Print Preview
			MenuItem filePrintPreview=menu.add(actions.filePrintPreview);
			filePrintPreview.setMnemonic(KeyEvent.VK_V);
			// Print
			MenuItem filePrint=menu.add(actions.filePrint);
			filePrint.setMnemonic(KeyEvent.VK_P);
			filePrint.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_P,Event.CTRL_MASK));
			////
			menu.addSeparator();
			// Properties
			MenuItem fileProperties=menu.add(actions.fileProperties);
			fileProperties.setMnemonic(KeyEvent.VK_I);
			fileProperties.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_ENTER,Event.ALT_MASK));
			// Exit
			MenuItem exit=menu.add(actions.fileExit);
			exit.setMnemonic(KeyEvent.VK_X);
			exit.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_F4,Event.ALT_MASK));
		}
		public void createEditMenu() {
			// create it
			Menu menu = new Menu("Edit");
			menu.setMnemonic('E');
			add(menu);
			// Undo
			MenuItem editUndo=menu.add(actions.editUndo);
			editUndo.setMnemonic('U');
			editUndo.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_Z,Event.CTRL_MASK));
			// Redo
			MenuItem editRedo=menu.add(actions.editRedo);
			editRedo.setMnemonic('R');
			editRedo.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_Y,Event.CTRL_MASK));
			////
			menu.addSeparator();
			// Cut
			MenuItem editCut=menu.add(actions.editCut);
			editCut.setMnemonic('T');
			editCut.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_X,Event.CTRL_MASK));
			// Copy
			MenuItem editCopy=menu.add(actions.editCopy);
			editCopy.setMnemonic('C');
			editCopy.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_C,Event.CTRL_MASK));
			// Paste
			MenuItem editPaste=menu.add(actions.editPaste);
			editPaste.setMnemonic('P');
			editPaste.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_V,Event.CTRL_MASK));
			// Paste Special
			MenuItem editPasteSpecial=menu.add(actions.editPasteSpecial);
			editPasteSpecial.setMnemonic('S');
			// Select All
			MenuItem editSelectAll=menu.add(actions.editSelectAll);
			editSelectAll.setMnemonic('A');
			editSelectAll.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_A,Event.CTRL_MASK));
			////
			menu.addSeparator();
			// Find
			MenuItem editFind=menu.add(actions.editFind);
			editFind.setMnemonic('F');
			editFind.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_F,Event.CTRL_MASK));
			// Find Again
			MenuItem editFindAgain=menu.add(actions.editFindAgain);
			editFindAgain.setMnemonic('G');
			editFindAgain.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_G,Event.CTRL_MASK));
			// Replace
			MenuItem editReplace=menu.add(actions.editReplace);
			editReplace.setMnemonic('R');
			editReplace.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_H,Event.CTRL_MASK));
			////
			menu.addSeparator();
			// Preferences
			MenuItem editPreferences=menu.add(actions.editPreferences);
			editPreferences.setMnemonic('N');
		}
		public void createWindowMenu() {
			// create it
			Menu menu = new Menu("Window");
			menu.setMnemonic('W');
			add(menu);
			// Arrange Windows...
			MenuItem arrange=menu.add(actions.windowArrange);
			arrange.setMnemonic(KeyEvent.VK_A);
			////
			menu.addSeparator();
		}
		public void createHelpMenu() {
			// create it
			Menu menu = new Menu("Help");
			menu.setMnemonic('H');
			add(menu);
			// Contents
			MenuItem helpContents=menu.add(actions.helpContents);
			helpContents.setMnemonic(KeyEvent.VK_C);
			helpContents.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_F1,0));
			menu.add(helpContents);
			// Index
			MenuItem helpIndex=menu.add(actions.helpIndex);
			helpIndex.setMnemonic(KeyEvent.VK_I);
			menu.add(helpIndex);
			// Search
			MenuItem helpSearch=menu.add(actions.helpSearch);
			helpSearch.setMnemonic(KeyEvent.VK_S);
			menu.add(helpSearch);
			////
			menu.addSeparator();
			// Tutorial
			MenuItem helpTutorial=menu.add(actions.helpTutorial);
			helpTutorial.setMnemonic(KeyEvent.VK_T);
			menu.add(helpTutorial);
			// What's This?
			MenuItem helpWhatsThis=menu.add(actions.helpWhatsThis);
			helpWhatsThis.setMnemonic(KeyEvent.VK_W);
			helpWhatsThis.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_F1,Event.SHIFT_MASK));
			menu.add(helpWhatsThis);
			////
			menu.addSeparator();
			// About Skunk Works
			MenuItem helpAbout=menu.add(actions.helpAbout);
			helpAbout.setMnemonic(KeyEvent.VK_A);
			menu.add(helpAbout);
		}
	}
	private class ToolBar extends gov.nasa.arc.l2tools.swing.ToolBar {
		public ToolBar() {
			super();
			setName("ToolBar");
			add(actions.fileOpen).setText("");
			add(actions.fileSave).setText("");
			addSeparator();
			add(actions.editUndo).setText("");
			add(actions.editRedo).setText("");
			addSeparator();
			add(actions.editCut).setText("");
			add(actions.editCopy).setText("");
			add(actions.editPaste).setText("");
			addSeparator();
			add(actions.editFind).setText("");
		}
	}
	private class Desktop extends gov.nasa.arc.l2tools.swing.Desktop {
		public Desktop() {
			super();
		}
	}	
	private class StatusBar extends gov.nasa.arc.l2tools.swing.StatusBar {
		public StatusBar() {
			super();
			gov.nasa.arc.l2tools.swing.StatusLabel label
			  = new gov.nasa.arc.l2tools.swing.StatusLabel("status");
			add(label);
		}
	}	
	Actions actions=new Actions();
	private class Actions {
		// File Actions
		public AbstractAction fileNew = new AbstractAction("New") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventFileNew(event);
			}
		};
		public AbstractAction fileOpen = new AbstractAction("Open",new ImageIcon(getClass().getResource("/open.gif"))) {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventFileOpen(event);
			}
		};
		public AbstractAction fileClose = new AbstractAction("Close") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventFileClose(event);
			}
		};
		public AbstractAction fileSave = new AbstractAction("Save",new ImageIcon(getClass().getResource("/save.gif"))) {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventFileSave(event);
			}
		};
		public AbstractAction fileSaveAs = new AbstractAction("Save As...") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventFileSaveAs(event);
			}
		};
		public AbstractAction filePageSetup = new AbstractAction("Page Setup...") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventFilePageSetup(event);
			}
		};
		public AbstractAction filePrintPreview = new AbstractAction("Print Preview...") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventFilePrintPreview(event);
			}
		};
		public AbstractAction filePrint = new AbstractAction("Print...") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventFilePrint(event);
			}
		};
		public AbstractAction fileProperties = new AbstractAction("Properties...") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventFileProperties(event);
			}
		};
		public AbstractAction fileExit = new AbstractAction("Exit") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventFileExit(event);
			}
		};
		// Edit
		public AbstractAction editUndo = new AbstractAction("Undo",new ImageIcon(getClass().getResource("/undo.gif"))) {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventEditUndo(event);
			}
		};
		public AbstractAction editRedo = new AbstractAction("Redo",new ImageIcon(getClass().getResource("/redo.gif"))) {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventEditRedo(event);
			}
		};
		public AbstractAction editCut = new AbstractAction("Cut",new ImageIcon(getClass().getResource("/cut.gif"))) {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventEditCut(event);
			}
		};
		public AbstractAction editCopy = new AbstractAction("Copy",new ImageIcon(getClass().getResource("/copy.gif"))) {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventEditCopy(event);
			}
		};
		public AbstractAction editPaste = new AbstractAction("Paste",new ImageIcon(getClass().getResource("/paste.gif"))) {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventEditPaste(event);
			}
		};
		public AbstractAction editPasteSpecial = new AbstractAction("Paste Special...") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventEditPasteSpecial(event);
			}
		};
		public AbstractAction editSelectAll = new AbstractAction("Select All") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventEditSelectAll(event);
			}
		};
		public AbstractAction editFind = new AbstractAction("Find...",new ImageIcon(getClass().getResource("/find.gif"))) {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventEditFind(event);
			}
		};
		public AbstractAction editFindAgain = new AbstractAction("Find Again") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventEditFindAgain(event);
			}
		};
		public AbstractAction editReplace = new AbstractAction("Replace...") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventEditReplace(event);
			}
		};
		public AbstractAction editPreferences = new AbstractAction("Preferences...") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventEditPreferences(event);
			}
		};
		// Window Actions
		public AbstractAction windowArrange = new AbstractAction("Arrange...") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventWindowArrange(event);
			}
		};
		// Help Actions
		public AbstractAction helpContents = new AbstractAction("Contents...") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventHelpContents(event);
			}
		};
		public AbstractAction helpIndex = new AbstractAction("Index...") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventHelpIndex(event);
			}
		};
		public AbstractAction helpSearch = new AbstractAction("Search...") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventHelpSearch(event);
			}
		};
		public AbstractAction helpTutorial = new AbstractAction("Tutorial") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventHelpTutorial(event);
			}
		};
		public AbstractAction helpWhatsThis = new AbstractAction("What's This?") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventHelpWhatsThis(event);
			}
		};
		public AbstractAction helpAbout = new AbstractAction("About Skunk Works...") {
			public void actionPerformed(java.awt.event.ActionEvent event) {
				eventHelpAbout(event);
			}
		};
		public Actions() {
			super();
		}
	}
/**
 * WorkspaceGUI constructor comment.
 */
public WorkspaceGUI() {
	this(new gov.nasa.arc.l2tools.swing.Frame("WorkspaceGUI"));
}
/**
 * WorkspaceGUI constructor comment.
 */
public WorkspaceGUI(gov.nasa.arc.l2tools.swing.RootPaneContainer frame) {
	this(frame,new gov.nasa.arc.l2tools.Workspace());
}
/**
 * WorkspaceGUI constructor comment.
 */
public WorkspaceGUI(gov.nasa.arc.l2tools.swing.RootPaneContainer frame, gov.nasa.arc.l2tools.Workspace workspace) {
	super(frame);
	getView().getRootPane().setDoubleBuffered(true);
	getView().getRootPane().setJMenuBar(new MenuBar());
	getView().setToolBar(new ToolBar());
	getView().setStatusBar(new StatusBar());
	getView().setContentPane(new Desktop());
	setWorkspace(workspace);
}
/**
 * The addPropertyChangeListener method was generated to support the propertyChange field.
 */
public synchronized void addPropertyChangeListener(java.beans.PropertyChangeListener listener) {
	getPropertyChange().addPropertyChangeListener(listener);
}
/**
 * The addPropertyChangeListener method was generated to support the propertyChange field.
 */
public synchronized void addPropertyChangeListener(java.lang.String propertyName, java.beans.PropertyChangeListener listener) {
	getPropertyChange().addPropertyChangeListener(propertyName, listener);
}
private void eventEditCopy(java.awt.event.ActionEvent event) {
}
private void eventEditCut(java.awt.event.ActionEvent event) {
}
private void eventEditFind(java.awt.event.ActionEvent event) {
}
private void eventEditFindAgain(java.awt.event.ActionEvent event) {
}
private void eventEditPaste(java.awt.event.ActionEvent event) {
}
private void eventEditPasteSpecial(java.awt.event.ActionEvent event) {
}
private void eventEditPreferences(java.awt.event.ActionEvent event) {
}
private void eventEditRedo(java.awt.event.ActionEvent event) {
}
private void eventEditReplace(java.awt.event.ActionEvent event) {
}
private void eventEditSelectAll(java.awt.event.ActionEvent event) {
}
private void eventEditUndo(java.awt.event.ActionEvent event) {
}
private void eventFileClose(java.awt.event.ActionEvent event) {
//	com.ibm.uvm.tools.DebugSupport.inspect(getView().getContentPane());
	try {
	((gov.nasa.arc.l2tools.swing.DesktopManager)((Desktop)getView().getContentPane()).getDesktopManager()).getActiveFrame().setClosed(true);
	} catch (java.beans.PropertyVetoException e) {}
}
private void eventFileExit(java.awt.event.ActionEvent event) {
	int response = 
		javax.swing.JOptionPane.showInternalConfirmDialog(getView().getContentPane(),
			"Are you sure you want to quit Skunk Works?","Exit Skunk Works",
			javax.swing.JOptionPane.YES_NO_OPTION,javax.swing.JOptionPane.QUESTION_MESSAGE);
	if (response==javax.swing.JOptionPane.YES_OPTION) {
		// TODO: Close up files
		System.exit(0);
	}
}
private void eventFileNew(java.awt.event.ActionEvent event) {
	ProjectGUI projectGUI = new ProjectGUI(new gov.nasa.arc.l2tools.swing.InternalFrame("Untitled Project",true,true,true,true),new gov.nasa.arc.l2tools.Project());
	getView().getContentPane().add((gov.nasa.arc.l2tools.swing.InternalFrame)projectGUI.getView());
	((gov.nasa.arc.l2tools.swing.InternalFrame)projectGUI.getView()).setVisible(true);
	try {
		((gov.nasa.arc.l2tools.swing.InternalFrame)projectGUI.getView()).setSelected(true);
	} catch (java.beans.PropertyVetoException vetoed) {
		// oh well
	}
}
private void eventFileOpen(java.awt.event.ActionEvent event) {
	javax.swing.JFileChooser fileChooser = new javax.swing.JFileChooser();
/*	javax.swing.filechooser.FileFilter filter = new javax.swing.filechooser.FileFilter() {
		public boolean accept(java.io.File f) {
			return (f.getName().endsWith(".xmpl"));
		}
		public String getDescription() {
	    return "Skunk Works File (*.xmpl)";
		}
	};
	fileChooser.setFileFilter(filter);
*/
	int returnVal = fileChooser.showOpenDialog(getView().getContentPane());
  if (returnVal==javax.swing.JFileChooser.APPROVE_OPTION) {
		System.out.println("You chose to open this file: " +
		  fileChooser.getSelectedFile().getName());
  }
}
private void eventFilePageSetup(java.awt.event.ActionEvent event) {
}
private void eventFilePrint(java.awt.event.ActionEvent event) {
}
private void eventFilePrintPreview(java.awt.event.ActionEvent event) {
}
private void eventFileProperties(java.awt.event.ActionEvent event) {
}
private void eventFileSave(java.awt.event.ActionEvent event) {
}
private void eventFileSaveAs(java.awt.event.ActionEvent event) {
}
private void eventHelpAbout(java.awt.event.ActionEvent event) {
	javax.swing.JOptionPane.showInternalMessageDialog(getView().getContentPane(),
		"Skunk Works Development Team:\n    Andrew Bachmann\n    Mark Shirley\n    Will Taylor\n    Steve Wragg",
		"About Skunk Works",javax.swing.JOptionPane.INFORMATION_MESSAGE);
}
private void eventHelpContents(java.awt.event.ActionEvent event) {
}
private void eventHelpIndex(java.awt.event.ActionEvent event) {
}
private void eventHelpSearch(java.awt.event.ActionEvent event) {
}
private void eventHelpTutorial(java.awt.event.ActionEvent event) {
}
private void eventHelpWhatsThis(java.awt.event.ActionEvent event) {
}
private void eventWindowArrange(java.awt.event.ActionEvent event) {
}
/**
 * The firePropertyChange method was generated to support the propertyChange field.
 */
public void firePropertyChange(java.beans.PropertyChangeEvent evt) {
	getPropertyChange().firePropertyChange(evt);
}
/**
 * The firePropertyChange method was generated to support the propertyChange field.
 */
public void firePropertyChange(java.lang.String propertyName, int oldValue, int newValue) {
	getPropertyChange().firePropertyChange(propertyName, oldValue, newValue);
}
/**
 * The firePropertyChange method was generated to support the propertyChange field.
 */
public void firePropertyChange(java.lang.String propertyName, java.lang.Object oldValue, java.lang.Object newValue) {
	getPropertyChange().firePropertyChange(propertyName, oldValue, newValue);
}
/**
 * The firePropertyChange method was generated to support the propertyChange field.
 */
public void firePropertyChange(java.lang.String propertyName, boolean oldValue, boolean newValue) {
	getPropertyChange().firePropertyChange(propertyName, oldValue, newValue);
}
/**
 * Accessor for the propertyChange field.
 */
protected java.beans.PropertyChangeSupport getPropertyChange() {
	if (propertyChange == null) {
		propertyChange = new java.beans.PropertyChangeSupport(this);
	};
	return propertyChange;
}
/**
 * Gets the workspace property (gov.nasa.arc.l2tools.Workspace) value.
 * @return The workspace property value.
 * @see #setWorkspace
 */
public gov.nasa.arc.l2tools.Workspace getWorkspace() {
	return fieldWorkspace;
}
/**
 * The hasListeners method was generated to support the propertyChange field.
 */
public synchronized boolean hasListeners(java.lang.String propertyName) {
	return getPropertyChange().hasListeners(propertyName);
}
/**
 * The removePropertyChangeListener method was generated to support the propertyChange field.
 */
public synchronized void removePropertyChangeListener(java.beans.PropertyChangeListener listener) {
	getPropertyChange().removePropertyChangeListener(listener);
}
/**
 * The removePropertyChangeListener method was generated to support the propertyChange field.
 */
public synchronized void removePropertyChangeListener(java.lang.String propertyName, java.beans.PropertyChangeListener listener) {
	getPropertyChange().removePropertyChangeListener(propertyName, listener);
}
/**
 * Sets the workspace property (gov.nasa.arc.l2tools.Workspace) value.
 * @param workspace The new value for the property.
 * @see #getWorkspace
 */
public void setWorkspace(gov.nasa.arc.l2tools.Workspace workspace) {
	gov.nasa.arc.l2tools.Workspace oldValue = fieldWorkspace;
	fieldWorkspace = workspace;
	firePropertyChange("workspace", oldValue, workspace);
}
}
