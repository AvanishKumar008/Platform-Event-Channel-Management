public with sharing class UtilDTO {
  //OptionDTO to create option in LWC
  public class OptionDTO implements Comparable {
    @AuraEnabled
    public String value;
    @AuraEnabled
    public String label;
    public OptionDTO(String label, String value) {
      this.value = value;
      this.label = label;
    }
    public Integer compareTo(Object other) {
      OptionDTO op = (OptionDTO) other;
      return this.label.compareTo(op.label);
    }
  }

  //Selected and Option for DualListBox LWC
  public class DualListDTO {
    @AuraEnabled
    public List<String> selectedOption;
    @AuraEnabled
    public List<OptionDTO> options;
  }
}
