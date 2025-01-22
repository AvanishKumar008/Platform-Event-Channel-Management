//Channel Member Wrapper class
public class ChannelMemberDTO {
    public String fullName;	//Channel Member Name
    public Metadata metadata;
    
    // Metadata inner wrapper
    public class Metadata {
        public EnrichedFields[] enrichedFields;
        public String eventChannel;	//Custom Channel Name
        public String selectedEntity;	//objectChangeEvent
        public String filterExpression;
    }
    public class EnrichedFields {
        public String name;	//fields Name
    }
}