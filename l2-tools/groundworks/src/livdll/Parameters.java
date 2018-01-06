// 
// * See the file "l2-tools/disclaimers-and-notices.txt" for 
// * information on usage and redistribution of this file, 
// * and for a DISCLAIMER OF ALL WARRANTIES. 
// 

/* Generated by Together */

package livdll;

public class Parameters {
    
    private String searchType = searchTypes[0];
    private String progressType = progressTypes[1];
    private String fcType = fcTypes[1];;
    private int maxCandidatesReturned = 20;
    private int maxCandidatesSearched = 1000;
    private int maxCutoffWeight = 100;
    private int maxHistoryCutoff = 10;
    private int maxTrajectoriesTracked = 10;
    private int maxCBFSCandidateClasses = 10;
    public static String[] searchTypes = { "cbfs", "cover" };
    public static String[] progressTypes = { "min", "full" };
    public static String[] fcTypes = { "extend", "prune-search", "find-fresh" };
    public static int[] maxCandidatesReturnedBounds = { 1, 1000 };
    public static int[] maxCandidatesSearchedBounds = { 100, 100000 };
    public static int[] maxCutoffWeightBounds = { 1, 1000 };
    public static int[] maxHistoryCutoffBounds = { 0, 100 };
    public static int[] maxTrajectoriesTrackedBounds = { 1, 100 };
    public static int[] maxCBFSCandidateClassesBounds = { 1, 100 };
    
    public void load(java.io.InputStream in) throws java.io.IOException {
        java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.InputStreamReader(in));
        java.util.HashMap hash = new java.util.HashMap(10);
        String line = reader.readLine();
        while(line != null) {
            int i = line.indexOf("=");
            if(i > -1 && line.length() > i) {
                hash.put(line.substring(0, i).trim(), line.substring(i + 1).trim());
                line = reader.readLine();
            }
        }
        try {
            setSearchType((String)hash.get("L2SearchMethod"));
        } catch(java.beans.PropertyVetoException e) { System.out.println(e); }
        if(searchType.equals("cbfs")) {
            String value = null;
            try {
                value = (String)hash.get("L2MaxCBFSCandidates");
                if(value != null) setMaxCandidatesReturned(Integer.decode(value).intValue());
            } catch(java.beans.PropertyVetoException e) { System.out.println(e); }
            try {
                value = (String)hash.get("L2MaxCBFSSearchSpace");
                if(value != null) setMaxCandidatesSearched(Integer.decode(value).intValue());
            } catch(java.beans.PropertyVetoException e) { System.out.println(e); }
            try {
                value = (String)hash.get("L2MaxCBFSCutoffWeight");
                if(value != null) setMaxCutoffWeight(Integer.decode(value).intValue());
            } catch(java.beans.PropertyVetoException e) { System.out.println(e); }
            try {
                value = (String)hash.get("L2MaxHistorySteps");
                if(value != null) setMaxHistoryCutoff(Integer.decode(value).intValue());
            } catch(java.beans.PropertyVetoException e) { System.out.println(e); }
            try {
                value = (String)hash.get("L2ProgressCmdType");
                if(value != null) setProgressType(value);
            } catch(java.beans.PropertyVetoException e) { System.out.println(e); }
            try {
                value = (String)hash.get("L2NumTrajectoriesTracked");
                if(value != null) setMaxTrajectoriesTracked(Integer.decode(value).intValue());
            } catch(java.beans.PropertyVetoException e) { System.out.println(e); }
            try {
                value = (String)hash.get("L2FindCandidatesCmdType");
                if(value != null) setFcType(value);
            } catch(java.beans.PropertyVetoException e) { System.out.println(e); }
            try {
                value = (String)hash.get("L2MaxCBFSCandidateClasses");
                if(value != null) setMaxCBFSCandidateClasses(Integer.decode(value).intValue());
            } catch(java.beans.PropertyVetoException e) { System.out.println(e); }
        }
        reader.close();
    }
    
    /** Getter for property searchType.
     * @return Value of property searchType.
     */
    public String getSearchType() {
        return searchType;
    }
    
    /** Setter for property searchType.
     * @param searchType New value of property searchType.
     */
    public void setSearchType(String searchType) throws java.beans.PropertyVetoException {
        boolean ok = false;
        searchType = searchType.toLowerCase();
        for(int i = 0; i < searchTypes.length; i++) {
            if(searchType.equals(searchTypes[i])) {
                ok = true; break;
            }
        }
        if(!ok) throw new java.beans.PropertyVetoException("Parameters.setSearchType() "+searchType+" not valid type.", null);
        this.searchType = searchType;
    }
    
    /** Getter for property progressType.
     * @return Value of property progressType.
     */
    public String getProgressType() {
        return progressType;
    }
    
    /** Setter for property progressType.
     * @param progressType New value of property progressType.
     */
    public void setProgressType(String progressType) throws java.beans.PropertyVetoException {
        boolean ok = false;
        progressType = progressType.toLowerCase();
        for(int i = 0; i < progressTypes.length; i++) {
            if(progressType.equals(progressTypes[i])) {
                ok = true; break;
            }
        }
        if(!ok) throw new java.beans.PropertyVetoException("Parameters.setProgressType() "+progressType+" not valid type.", null);
        this.progressType = progressType;
    }
    
    /** Getter for property fcType.
     * @return Value of property fcType.
     */
    public String getFcType() {
        return fcType;
    }
    
    /** Setter for property fcType.
     * @param fcType New value of property fcType.
     */
    public void setFcType(String fcType) throws java.beans.PropertyVetoException {
        boolean ok = false;
        fcType = fcType.toLowerCase();
        for(int i = 0; i < fcTypes.length; i++) {
            if(fcType.equals(fcTypes[i])) {
                ok = true; break;
            }
        }
        if(!ok) throw new java.beans.PropertyVetoException("Parameters.setFcType() "+fcType+" not valid type.", null);
        this.fcType = fcType;
    }
    
    /** Getter for property maxCandidatesReturned.
     * @return Value of property maxCandidatesReturned.
     */
    public int getMaxCandidatesReturned() {
        return maxCandidatesReturned;
    }
    
    /** Setter for property maxCandidatesReturned.
     * @param maxCandidatesReturned New value of property maxCandidatesReturned.
     */
    public void setMaxCandidatesReturned(int maxCandidatesReturned) throws java.beans.PropertyVetoException {
        if(maxCandidatesReturned < maxCandidatesReturnedBounds[0])
            throw new java.beans.PropertyVetoException("Parameters.setMaxCandidatesReturned() "+maxCandidatesReturned+" < "+maxCandidatesReturnedBounds[0], null);
        if(maxCandidatesReturned > maxCandidatesReturnedBounds[1])
            throw new java.beans.PropertyVetoException("Parameters.setMaxCandidatesReturned() "+maxCandidatesReturned+" > "+maxCandidatesReturnedBounds[1], null);
        this.maxCandidatesReturned = maxCandidatesReturned;
    }
    
    /** Getter for property maxCandidatesSearched.
     * @return Value of property maxCandidatesSearched.
     */
    public int getMaxCandidatesSearched() {
        return maxCandidatesSearched;
    }
    
    /** Setter for property maxCandidatesSearched.
     * @param maxCandidatesSearched New value of property maxCandidatesSearched.
     */
    public void setMaxCandidatesSearched(int maxCandidatesSearched) throws java.beans.PropertyVetoException {
        if(maxCandidatesSearched < maxCandidatesSearchedBounds[0])
            throw new java.beans.PropertyVetoException("Parameters.setMaxCandidatesSearched() "+maxCandidatesSearched+" < "+maxCandidatesSearchedBounds[0], null);
        if(maxCandidatesSearched > maxCandidatesSearchedBounds[1])
            throw new java.beans.PropertyVetoException("Parameters.setMaxCandidatesSearched() "+maxCandidatesSearched+" > "+maxCandidatesSearchedBounds[1], null);
        this.maxCandidatesSearched = maxCandidatesSearched;
    }
    
    /** Getter for property maxCutoffWeight.
     * @return Value of property maxCutoffWeight.
     */
    public int getMaxCutoffWeight() {
        return maxCutoffWeight;
    }
    
    /** Setter for property maxCutoffWeight.
     * @param maxCutoffWeight New value of property maxCutoffWeight.
     */
    public void setMaxCutoffWeight(int maxCutoffWeight) throws java.beans.PropertyVetoException {
        if(maxCutoffWeight < maxCutoffWeightBounds[0])
            throw new java.beans.PropertyVetoException("Parameters.setMaxCutoffWeight() "+maxCutoffWeight+" < "+maxCutoffWeightBounds[0], null);
        if(maxCutoffWeight > maxCutoffWeightBounds[1])
            throw new java.beans.PropertyVetoException("Parameters.setMaxCutoffWeight() "+maxCutoffWeight+" > "+maxCutoffWeightBounds[1], null);
        this.maxCutoffWeight = maxCutoffWeight;
    }
    
    /** Getter for property maxHistoryCutoff.
     * @return Value of property maxHistoryCutoff.
     */
    public int getMaxHistoryCutoff() {
        return maxHistoryCutoff;
    }
    
    /** Setter for property maxHistoryCutoff.
     * @param maxHistoryCutoff New value of property maxHistoryCutoff.
     */
    public void setMaxHistoryCutoff(int maxHistoryCutoff) throws java.beans.PropertyVetoException {
        if(maxHistoryCutoff < maxHistoryCutoffBounds[0])
            throw new java.beans.PropertyVetoException("Parameters.setMaxHistoryCutoff() "+maxHistoryCutoff+" < "+maxHistoryCutoffBounds[0], null);
        if(maxHistoryCutoff > maxCutoffWeightBounds[1])
            throw new java.beans.PropertyVetoException("Parameters.setMaxHistoryCutoff() "+maxHistoryCutoff+" > "+maxHistoryCutoffBounds[1], null);
        this.maxHistoryCutoff = maxHistoryCutoff;
    }
    
    /** Getter for property maxTrajectoriesTracked.
     * @return Value of property maxTrajectoriesTracked.
     */
    public int getMaxTrajectoriesTracked() {
        return maxTrajectoriesTracked;
    }
    
    /** Setter for property maxTrajectoriesTracked.
     * @param maxTrajectoriesTracked New value of property maxTrajectoriesTracked.
     */
    public void setMaxTrajectoriesTracked(int maxTrajectoriesTracked) throws java.beans.PropertyVetoException {
        if(maxTrajectoriesTracked < maxTrajectoriesTrackedBounds[0])
            throw new java.beans.PropertyVetoException("Parameters.setMaxTrajectoriesTracked() "+maxTrajectoriesTracked+" < "+maxTrajectoriesTrackedBounds[0], null);
        if(maxTrajectoriesTracked > maxTrajectoriesTrackedBounds[1])
            throw new java.beans.PropertyVetoException("Parameters.setMaxTrajectoriesTracked() "+maxTrajectoriesTracked+" > "+maxTrajectoriesTrackedBounds[1], null);
        this.maxTrajectoriesTracked = maxTrajectoriesTracked;
    }
    
    /** Getter for property maxCBFSCandidateClasses.
     * @return Value of property maxCBFSCandidateClasses.
     */
    public int getMaxCBFSCandidateClasses() {
        return maxCBFSCandidateClasses;
    }
    
    /** Setter for property maxCBFSCandidateClasses.
     * @param maxCBFSCandidateClasses New value of property maxCBFSCandidateClasses.
     */
    public void setMaxCBFSCandidateClasses(int maxCBFSCandidateClasses) throws java.beans.PropertyVetoException {
        if(maxCBFSCandidateClasses < maxCBFSCandidateClassesBounds[0])
            throw new java.beans.PropertyVetoException("Parameters.setMaxCBFSCandidateClasses() "+maxCBFSCandidateClasses+" < "+maxCBFSCandidateClassesBounds[0], null);
        if(maxCBFSCandidateClasses > maxCBFSCandidateClassesBounds[1])
            throw new java.beans.PropertyVetoException("Parameters.setMaxCBFSCandidateClasses() "+maxCBFSCandidateClasses+" > "+maxCBFSCandidateClassesBounds[1], null);
        this.maxCBFSCandidateClasses = maxCBFSCandidateClasses;
    }
    
}