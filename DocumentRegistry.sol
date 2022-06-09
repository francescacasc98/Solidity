pragma solidity ^0.5.6;


/**
 * @title A registry of document protocols, and theirs revisions, on the Ethereum Blockchain
 * @author Alessandro Fraschetti
 */
contract DocumentRegistry
{
    string constant private version = "0.0.1";
    address internal owner;
    struct Document
    {
        address signer;
        bytes32 protocol; //hash documento
        uint date;
        bytes32 revisionOfProtocol; //hash documento revisionato
        uint revisionNumber;
        bytes32 revisionedByProtocol; //hash documento precedente revisione
    }
    mapping(bytes32 => Document) internal registry;

    event Registered(address indexed _signer, bytes32 _protocol, uint _date);
    event Revisioned(address indexed _signer, bytes32 _protocol, uint _date);
    event AlreadyRegistered(address indexed _signer, bytes32 _protocol, uint _date);
    event DocumentNotPresent(address indexed _signer, bytes32 _protocol, uint _date);

    /**
     * @notice Creates a new document protocol registry
     */
    constructor()
    public
    {
        owner = msg.sender; //persona che si sta attualmente connettendo con il contratto
    }

    /**
     * @notice Returns the contract version
     * @return the contract version
     */
    function getVersion()
    external pure returns (string memory)
    {
         return version;
    }

    /**
     * @notice Records a document identified by its 32 bytes hash (the protocol)
     *         Emit an event Registered in case of success
     * @param _protocol the document protocol
     */
    function registerDocument(bytes32 _protocol)
    external
    {
        uint date = now;

        if(!isRegistered(_protocol)) {
        registry[_protocol].signer = msg.sender;
        registry[_protocol].protocol = _protocol;
        registry[_protocol].date = date;
        registry[_protocol].revisionOfProtocol = _protocol;
        registry[_protocol].revisionNumber = 1;
        registry[_protocol].revisionedByProtocol = _protocol;
        emit Registered(msg.sender, _protocol, date);
         }
         else {
            emit AlreadyRegistered(msg.sender, _protocol, date);
        }
    }

    /**
     * @notice Records a document revision identified by its 32 bytes hash (the protocol)
     *         Emit an event Registered and an event Revisioned in case of success
     * @param _protocol the new document protocol
     * @param _revisionOfProtocol the revisioned document protocol
     */
    function registerDocumentRevision(bytes32 _protocol, bytes32 _revisionOfProtocol)
    external
    {
        uint date = now;
           if(isRegistered(_revisionOfProtocol) && !isRegistered(_protocol)) {
            registry[_protocol].signer = msg.sender;
            registry[_protocol].protocol = _protocol;
            registry[_protocol].date = date;
            registry[_protocol].revisionOfProtocol = _revisionOfProtocol;
            registry[_protocol].revisionNumber = registry[_revisionOfProtocol].revisionNumber + 1;
            registry[_protocol].revisionedByProtocol = _protocol;
            emit Registered(msg.sender, _protocol, date);

            registry[_revisionOfProtocol].revisionedByProtocol = _protocol;
            emit Revisioned(msg.sender, _revisionOfProtocol, date);
           }
           else {
               if(!isRegistered(_revisionOfProtocol)) {
                    emit DocumentNotPresent(msg.sender, _revisionOfProtocol, date);
               } else {
                   if(isRegistered(_protocol)) {
                   emit AlreadyRegistered(msg.sender, _protocol, date);
               }
            }
               
              
           }
           
         
              
   }

    /**
     * @notice Verify a document identified by its protocol was recorded in the registry
     * @param _protocol the document protocol
     * @return if document protocol was recorded previsouly in the registry
     */
    function isRegistered(bytes32 _protocol)
    internal view returns (bool)
    {
        return (registry[_protocol].protocol == _protocol);
    }

    /**
     * @notice Verify a document identified by its protocol was revisioned in the registry
     * @param _protocol the document protocol
     * @return bool if document was revisioned in the registry
     */
    function isRevisioned(bytes32 _protocol)
    internal view returns (bool)
    {
        return (registry[_protocol].revisionedByProtocol != _protocol);
    }

    /**
     * @notice Verify a document identified by its protocol is a revision
     * @param _protocol the document protocol
     * @return bool if document protocol is a revision in the registry
     */
    function isRevision(bytes32 _protocol)
    external view returns (bool)
    {
        return (registry[_protocol].revisionOfProtocol != _protocol);
    }

    /**
     * @notice Returns the last document protocol revision of the document identified by its protocol
     * @param _protocol the document protocol
     * @return bytes32 the last document protocol revision in the registry
     */
    function getLastRevision(bytes32 _protocol)
    public view returns (bytes32)
    {
        bytes32 revision = "";
        
        if (registry[_protocol].protocol == _protocol)
        {
            revision = _protocol;
            while (registry[revision].revisionedByProtocol != registry[revision].protocol)
                revision = registry[revision].revisionedByProtocol;
                
        }

        return (revision);
    }

    /**
     * @notice Returns the document revision history of the document identified by its protocol
     * @param _protocol the document protocol
     * @return bytes32[] the array of document revisions
     */
    function getRevisionHistory(bytes32 _protocol)
    external view returns (bytes32[] memory)
    {
     
        bytes32 temp;
        bytes32[] memory history;
        uint index = 0;
        if (registry[_protocol].protocol == _protocol) {
            history= new bytes32[](registry[_protocol].revisionNumber);
            temp=_protocol;
            history[index]=temp;
            for(index=1; index<registry[_protocol].revisionNumber; index++) {
                 temp=registry[_protocol].revisionOfProtocol;
                 history[index]=temp;
            }
        
        }
        

        return history;
    }

}