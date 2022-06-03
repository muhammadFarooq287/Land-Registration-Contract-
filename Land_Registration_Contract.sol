// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";

/*
*@Author Muhammad Farooq BLK-Cohort-3
*@Date 3 JUNE 2022
*@title Land Registration
*@dev Buying, selling and Transfer of ownership of Land from Seller to Buyer.
*/

contract landRegistration is Ownable
{
    struct landRegistry{
        address landOwner;
        uint landId;
        uint area;
        string city;
        string state;
        uint landPriceInWei;
        uint propertyPID;
    }

    struct buyerDetails{
        string Name;
        uint256 Age;
        string city;
        string CNIC;
        string eMail;
    } 

    struct sellerDetails{
        string Name;
        uint256 Age;
        string city;
        string CNIC;
        string eMail;
    }

    struct landInspectorDetails{
        address landInspectorAddress;
        string Name;
        uint Age;
        string designation;
    }

    /**
    *
    *@dev Mapping Used to store land details, Land Inspector details,
    *     Seller Details, Buyer Details, Seller Verified Address,
    *     Buyer Verified Address and Verified Land ID
    *
    */
    mapping (uint => landRegistry) private lands;
    mapping (uint => landInspectorDetails) private inspectorMapping;
    mapping (address => sellerDetails) private sellerMapping;
    mapping (address => buyerDetails) private buyerMapping;
    mapping (address => bool) private verifySeller;
    mapping (address => bool) private verifyBuyer;
    mapping (uint => bool) private verifyLandID;

    /**
    *
    *@dev Global Variables used in Mapping.
    *     TO store Seller and Buyer Address
    *     So that we can use again.
    *
    */

    uint private inspectorId=1;
    uint private LandID=1;
    address public sellerAddress;
    address public buyerAddress;
    bool landPricePaid;

    /**
    *
    *@dev Events used to produce logs when Land Inspector enter its details,
    *     Buyer is verifier, Seller is verified, Land ID is verified,
    *     Buyer pays the land price to Seller
    *     and Seller Transfers Ownership of Land to Buyer Address.
    *
    */ 
    event landInspectorHired(address ownerAddress, string Name);

    event BuyerVerified(address _buyerAddress, string );

    event SellerVerified(address _sellerAddress, string ); 

    event LandVerified(address _landOwner, uint LandID);

    event transferLandPrice(address _buyerAddress, address _sellerAddress, uint _landID, uint _landPrice);

    event transferOwnershipLog(address _currentOwner, address _newOwner, uint _landID);

    /**
    *
    *@dev Modifier used to check that the sender of function is 
    *     whether verified Seller or not, verifier Buyer or Not,
    *     Land is Verified or Not.
    *
    */
    modifier IsVerifiedSeller()
    {
        require(verifySeller[msg.sender],"Unverified Seller");
        _;
    }

    modifier IsVerifiedBuyer()
    {
        require(verifyBuyer[msg.sender],"Unverified Buyer");
        _;
    }

    modifier IsVerifiedLand(uint _landId)
    {
        require(verifyLandID[_landId],"Unverified Land ID");
        _;
    }

    /*
    *@dev Legal body of contract (Land Inspector) Data is registered.
    *
    *@Requirement Only the owner of contract can Register Land Inspector Details.
    */
    
    function landInspectorData(
        string memory _Name, uint _Age, string memory _designation
    ) public onlyOwner
    {
        inspectorMapping[inspectorId]=landInspectorDetails(msg.sender, _Name, _Age, _designation);
        emit landInspectorHired(msg.sender, _Name);
    }

    /*
    *@dev Seller will register himself/herself and save his/her Details at his/her address.
    *
    *@param Seller's Name, Age, City, CNIC, Email.
    *
    */

    function registerSeller(
        string memory _Name,uint _Age,string memory  _city,string memory _CNIC,string memory _eMail
    ) external 
    {
        sellerAddress = msg.sender;
        require(sellerAddress!=buyerAddress, "Seller can't be Buyer");
        sellerMapping[sellerAddress]=sellerDetails(_Name, _Age, _city, _CNIC, _eMail);
    }

    /*
    *@dev Land Inspector will verify seller details.
    *
    *@Requirement Only Owner of Contract(Land Inspector) can verify seller address and its details.
    *
    *@param Seller's address
    */

    function VerifySeller( address _SellerAddress)
    public onlyOwner
    {
        verifySeller[_SellerAddress] = true;

        emit SellerVerified(_SellerAddress, "Seller is Verified");
    }

    /*
    *@dev Seller will upload land details.
    *
    *@Requirement Only verified seller can upload land details.
    *
    *@param Land's unique ID, Area, City, State, Price in wei, Property PID
    */    

    function uploadLandDetails(
        uint _landId, uint _area, string memory _city, string memory _state, uint _landPriceInWei, uint _propertyPID
    ) external IsVerifiedSeller 
    {
        lands[LandID]=landRegistry(msg.sender, _landId, _area, _city, _state, _landPriceInWei, _propertyPID);
    }

    /*
    *@dev Land Inspector will verify Land details by using Land ID.
    *
    *@Requirement Only Owner of Contract(Land Inspector) can verify land details entered by Seller.
    *
    *@param Land ID
    */

    function verifyLandId( uint _Land_ID)
    public onlyOwner
    {
        require(lands[LandID].landId == _Land_ID, "Incorrect Land ID");
        verifyLandID[_Land_ID]= true;

        emit LandVerified(lands[LandID].landOwner, _Land_ID);
    }

    /*
    *@dev Seller can update his/her Details.
    *
    *@Requirement Only verified seller can update his/her details.
    *
    *@param Seller's Name, Age, City, CNIC, Email.
    */

    function updateSeller(
        string memory _Name,uint _Age,string memory  _city,string memory _CNIC,string memory _eMail
    ) external IsVerifiedSeller
    {
        sellerMapping[msg.sender].Name= _Name;
        sellerMapping[msg.sender].Age= _Age;
        sellerMapping[msg.sender].city= _city;
        sellerMapping[msg.sender].CNIC= _CNIC;
        sellerMapping[msg.sender].eMail= _eMail;
    }

    /*
    *@dev To check Whether The Seller is Verified or Not.
    *
    *@param Seller's Address.
    *
    */

    function sellerIsVerified(address _sellerAddress) 
    external view returns(bool)
    {
        if (verifySeller[_sellerAddress])
        {
            return true;
        }
        else{
            return false;
        } 
    }

    /*
    *@dev To Get land Details
    *
    *@param Land ID
    *
    */

    function getLandDetailsByID (uint _landId
    ) external view returns (address, uint, uint , string memory, string memory, uint, uint)
    {
        require(_landId == lands[LandID].landId,"Incorrect Land ID");
        return (lands[LandID].landOwner, lands[LandID].landId, lands[LandID].area, lands[LandID].city, lands[LandID].state, lands[LandID].landPriceInWei, lands[LandID].propertyPID) ;
    }

    /*
    *@dev To find Who is the Owner of Land.
    *
    *@param Land ID
    *
    */
    
    function getLandOwnerByID (uint _landId
    ) external view returns (address)
    {
        require(_landId == lands[LandID].landId,"Incorrect Land ID");
        return lands[LandID].landOwner;
    }

     /*
    *@dev Buyer will register himself/herself and save his/her Details at his/her address.
    *
    *@param Buyer's Name, Age, City, CNIC, Email.
    *
    */

    function registerBuyer(
        string memory _Name,uint _Age,string memory  _city,string memory _CNIC,string memory _eMail
    ) external 
    {
        buyerAddress = msg.sender;
        require(buyerAddress!=sellerAddress, "Seller can't be Buyer");
        buyerMapping[buyerAddress]=buyerDetails(_Name, _Age, _city, _CNIC, _eMail);
    }

    /*
    *@dev Land Inspector will verify buyer details.
    *
    *@Requirement Only Owner of Contract(Land Inspector) can verify buyer address and its details.
    *
    *@param Buyer's address
    */

    function VerifyBuyer( address _buyerAddress)
    public onlyOwner
    {
        verifyBuyer[_buyerAddress] = true;

        emit BuyerVerified(msg.sender, "Buyer is Verified");
    }

    /*
    *@dev Buyer can update his/her Details.
    *
    *@Requirement Only verified Buyer can update his/her details.
    *
    *@param Buyer's Name, Age, City, CNIC, Email.
    */

     function updateBuyer(
        string memory _Name,uint _Age,string memory  _city,string memory _CNIC,string memory _eMail
    ) external IsVerifiedBuyer
    {
        buyerMapping[msg.sender].Name= _Name;
        buyerMapping[msg.sender].Age= _Age;
        buyerMapping[msg.sender].city= _city;
        buyerMapping[msg.sender].CNIC= _CNIC;
        buyerMapping[msg.sender].eMail= _eMail;
    }

    /*
    *@dev To check Whether The Buyer is Verified or Not.
    *
    *@param Buyer's Address.
    *
    */

    function buyerIsVerified(address _buyerAddress) 
    external view returns(bool)
    {
        if (verifyBuyer[_buyerAddress])
        {
            return true;
        }
        else{
            return false;
        } 
    }

    /*
    *@dev To check The current owner of land.
    *
    */

    function currentOwnerOFLand () 
    external view returns(address)
    {
        return lands[LandID].landOwner;
    }

    /*
    *@dev Buyer will transfer land price to seller and buy the land.
    *
    *@Requirement Only verified Buyer with Verified Land ID can Buy land.
    *
    *@param Seller's address, Land ID, Land price which is msg.value.
    */

    function buyLand(address payable _sellerAddress, uint _landId)
    public IsVerifiedBuyer IsVerifiedLand(_landId) payable returns(uint, bool)
    {
        require(verifySeller[_sellerAddress], "Unverified Seller");
        require(lands[LandID].landPriceInWei==msg.value, "Recheck Your Land Price in wei.");

        _sellerAddress.transfer(msg.value);
        landPricePaid = true;

        emit transferLandPrice(msg.sender, _sellerAddress, _landId, msg.value);
        return (address(this).balance, true);
    } 

    /*
    *@dev Seller will transfer land ownership from seller to buyer.
    *
    *@Requirement Only verified seller can transfer ownership.
    *
    *@param Buyer's address.
    */

    function changeOwnership (address _buyerAddress)
    public IsVerifiedSeller payable returns(address, string memory)
    {
        require(verifyBuyer[_buyerAddress], "Unverified Buyer");
        require(landPricePaid, "Price Not Paid");
        lands[LandID].landOwner= _buyerAddress;

        emit transferOwnershipLog(msg.sender, _buyerAddress, lands[LandID].landId);
        return (lands[LandID].landOwner, "New Owner of Land");
    }

    /*
    *@dev To check Whether The Land is Verified or Not.
    *
    *@param Land ID.
    *
    */

    function LandIsVerified(uint _landId) 
    external view returns(bool)
    {
        if (verifyLandID[_landId])
        {
            return true;
        }
        else{
            return false;
        }
    }

    /*
    *@dev To Get land Inspector's Details
    *
    */

    function GetLandInspectorData()
    external view returns(address, string memory, uint, string memory)
    {
        return(inspectorMapping[inspectorId].landInspectorAddress, inspectorMapping[inspectorId].Name, inspectorMapping[inspectorId].Age, inspectorMapping[inspectorId].designation );
    }

    /*
    *@dev To Get land City
    *
    *@param Land ID
    *
    */

    function getLandCityByID (uint _landId
    ) external view returns (string memory)
    {
        require(lands[LandID].landId == _landId ,"Incorrect Land ID");
        return lands[LandID].city;
    }

    /*
    *@dev To Get land price
    *
    *@param Land ID
    *
    */

    function getLandPriceByID (uint _landId
    ) external view returns (uint)
    {
        require(lands[LandID].landId == _landId ,"Incorrect Land ID");
        return lands[LandID].landPriceInWei;
    }

    /*
    *@dev To Get land area
    *
    *@param Land ID
    *
    */

    function getLandAreaByID (uint _landId
    ) external view returns (uint)
    {
        require(lands[LandID].landId == _landId ,"Incorrect Land ID");
        return lands[LandID].area;
    }

    /*
    *@dev To Check whether this address is seller or not.
    *
    */

    function isSeller()
    external view returns(bool)
    {
        if(msg.sender == sellerAddress)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    /*
    *@dev To Check whether this address is buyer or not.
    *
    */

    function isBuyer()
    external view returns(bool)
    {
        if(msg.sender == buyerAddress)
        {
            return true;
        }
        else
        {
            return false;
        }
    }    
 }
