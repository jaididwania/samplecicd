/**
 * @description Comprehensive test class for FetchMembershipInfo
 * @author Generated Test Class
 * @date 2025
 */
@IsTest
private class FetchMembershipInfoTest {
    
    // Test data constants
    private static final String TEST_PRODUCT_ID = '12345';
    private static final String TEST_PRODUCT_ID_2 = '67890';
    private static final String TEST_BRAND_ID = 'BRAND001';
    private static final String TEST_USER_EMAIL = 'testuser@fetchmembershiptest.com';
    private static final String TEST_CONTACT_EMAIL = 'testcontact@fetchmembershiptest.com';
    
    /**
     * @description Test setup method to create common test data
     * Creates User, Contact, Account, and Membership records for testing
     */
    @TestSetup
    static void setupTestData() {
        // Create test profile (use existing Standard User profile)
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Create test account (Person Account)
        Account testAccount = new Account(
            FirstName = 'Test',
            LastName = 'User Account',
            PersonEmail = TEST_CONTACT_EMAIL,
            DATE_SIGNUP_LATEST__c = Date.today().addDays(-30)
        );
        insert testAccount;
        
        // Get the contact created by person account
        Contact testContact = [SELECT Id FROM Contact WHERE AccountId = :testAccount.Id LIMIT 1];
        
        // Create test user linked to contact
        User testUser = new User(
            Username = TEST_USER_EMAIL,
            Email = TEST_USER_EMAIL,
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            ContactId = testContact.Id
        );
        insert testUser;
        
        // Create test memberships
        List<Membership__c> testMemberships = new List<Membership__c>();
        
        // Active membership
        testMemberships.add(new Membership__c(
            Person_Account_Customer__c = testAccount.Id,
            Product_ID__c = Decimal.valueOf(TEST_PRODUCT_ID),
            Customer_Id__c = 'CUST001',
            Active__c = true,
            Expiration_date__c = Date.today().addDays(30),
            Next_Payment_Date__c = Date.today().addDays(15),
            Barcode__c = 'BC123456789',
            SSPAN__c = '1234',
            VEHICLE_YEAR__c = '2023',
            VEHICLE_MODEL__c = 'Model S',
            VEHICLE_MAKE__c = 'Tesla',
            VEHICLE_VIN__c = 'VIN123456789',
            VEHICLE_COLOR__c = 'Red',
            VEHICLE_PLATE__c = 'ABC123',
            VEHICLE_STATE__c = 'CA',
            VEHICLEGUID__c = 'GUID123',
            SIGNUP_TYPE__c = 'Online'
        ));
        
        // Another active membership with different product
        testMemberships.add(new Membership__c(
            Person_Account_Customer__c = testAccount.Id,
            Product_ID__c = Decimal.valueOf(TEST_PRODUCT_ID_2),
            Customer_Id__c = 'CUST002',
            Active__c = true,
            Expiration_date__c = Date.today().addDays(60),
            Next_Payment_Date__c = Date.today().addDays(30)
        ));
        
        // Inactive membership (should not appear in results)
        testMemberships.add(new Membership__c(
            Person_Account_Customer__c = testAccount.Id,
            Product_ID__c = Decimal.valueOf('99999'),
            Customer_Id__c = 'CUST003',
            Active__c = false
        ));
        
        insert testMemberships;
    }
    
    /**
     * @description Mock class for Data Cloud DMO queries
     * Implements the mock SOQL pattern for Memberships__dlm
     */
    private class MembershipsDLMMock implements System.StubProvider {
        private List<Memberships__dlm> mockRecords;
        
        public MembershipsDLMMock(List<Memberships__dlm> records) {
            this.mockRecords = records != null ? records : new List<Memberships__dlm>();
        }
        
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
                                     Type returnType, List<Type> listOfParamTypes, 
                                     List<String> listOfParamNames, List<Object> listOfArgs) {
            return mockRecords;
        }
    }
    
    /**
     * @description Creates mock Memberships__dlm records for testing
     */
    private static List<Memberships__dlm> createMockMembershipsDLM() {
        List<Memberships__dlm> mockRecords = new List<Memberships__dlm>();
        
        // Mock record for TEST_PRODUCT_ID
        Memberships__dlm mock1 = (Memberships__dlm) Test.createStub(Memberships__dlm.class, new Map<String, Object>{
            'PRODUCT_ID__c' => TEST_PRODUCT_ID,
            'BENEFITS__c' => 'Unlimited Washes|Free Vacuums|Priority Service',
            'BRAND_ICON_KEY__c' => 'premium-icon',
            'COLOR_CODE__c' => '#FF5733',
            'FULL_PRICE__c' => 29.99,
            'LOGO_KEY__c' => 'premium-logo',
            'MEMBERSHIP_SUB_TYPE__c' => 'Premium',
            'MEMBERSHIP_TYPE__c' => 'Monthly',
            'NUM_OF_MONTHS__c' => 1,
            'PRODUCT_DESCRIPTION__c' => 'Premium monthly membership',
            'PROMO_PRICE__c' => 19.99,
            'USER_FACING_DESCRIPTION__c' => 'Best value for frequent washers',
            'USERFACING_NAME__c' => 'Premium Monthly',
            'PRODUCT_TYPE__c' => 'Subscription',
            'WASH_BRAND_ID__c' => TEST_BRAND_ID
        });
        mockRecords.add(mock1);
        
        // Mock record for TEST_PRODUCT_ID_2
        Memberships__dlm mock2 = (Memberships__dlm) Test.createStub(Memberships__dlm.class, new Map<String, Object>{
            'PRODUCT_ID__c' => TEST_PRODUCT_ID_2,
            'BENEFITS__c' => 'Basic Washes|Standard Service',
            'BRAND_ICON_KEY__c' => 'basic-icon',
            'COLOR_CODE__c' => '#33FF57',
            'FULL_PRICE__c' => 19.99,
            'LOGO_KEY__c' => 'basic-logo',
            'MEMBERSHIP_SUB_TYPE__c' => 'Basic',
            'MEMBERSHIP_TYPE__c' => 'Monthly',
            'NUM_OF_MONTHS__c' => 1,
            'PRODUCT_DESCRIPTION__c' => 'Basic monthly membership',
            'PROMO_PRICE__c' => 14.99,
            'USER_FACING_DESCRIPTION__c' => 'Great starter option',
            'USERFACING_NAME__c' => 'Basic Monthly',
            'PRODUCT_TYPE__c' => 'Subscription',
            'WASH_BRAND_ID__c' => TEST_BRAND_ID
        });
        mockRecords.add(mock2);
        
        return mockRecords;
    }
    
    /**
     * @description Test FetchMembershipInfo method with valid user and memberships
     */
    @IsTest
    static void testFetchMembershipInfo_Success() {
        User testUser = [SELECT Id, ContactId FROM User WHERE Email = :TEST_USER_EMAIL LIMIT 1];
        
        Test.startTest();
        System.runAs(testUser) {
            // Set up DMO mock
            List<Memberships__dlm> mockDMORecords = createMockMembershipsDLM();
            Test.setMock(HttpCalloutMock.class, new MembershipsDLMMock(mockDMORecords));
            
            String result = FetchMembershipInfo.FetchMembershipInfo();
            
            // Verify result is not null and properly formatted
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertNotEquals('{}', result, 'Result should not be empty');
            
            // Deserialize and verify structure
            Map<Id, Map<String, String>> resultMap = 
                (Map<Id, Map<String, String>>) JSON.deserialize(result, Map<Id, Map<String, String>>.class);
            
            System.assertEquals(2, resultMap.size(), 'Should return 2 active memberships');
            
            // Verify membership data structure
            for (Id membershipId : resultMap.keySet()) {
                Map<String, String> membershipData = resultMap.get(membershipId);
                System.assert(membershipData.containsKey('membershipExpDate'), 'Should contain expiration date');
                System.assert(membershipData.containsKey('nextPaymentDate'), 'Should contain next payment date');
                System.assert(membershipData.containsKey('membershipBarCode'), 'Should contain barcode');
            }
        }
        Test.stopTest();
    }
    
    /**
     * @description Test FetchMembershipInfo with user having no contact
     */
    @IsTest
    static void testFetchMembershipInfo_NoContact() {
        // Create user without contact
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userWithoutContact = new User(
            Username = 'nocontact@test.com',
            Email = 'nocontact@test.com',
            FirstName = 'No',
            LastName = 'Contact',
            Alias = 'nocont',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert userWithoutContact;
        
        Test.startTest();
        System.runAs(userWithoutContact) {
            String result = FetchMembershipInfo.FetchMembershipInfo();
            System.assertEquals('{}', result, 'Should return empty map for user without contact');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test FetchMembershipInfo with user having no active memberships
     */
    @IsTest
    static void testFetchMembershipInfo_NoMemberships() {
        // Create user with contact but no memberships
        Account newAccount = new Account(
            FirstName = 'No',
            LastName = 'Memberships',
            PersonEmail = 'nomemberships@test.com'
        );
        insert newAccount;
        
        Contact newContact = [SELECT Id FROM Contact WHERE AccountId = :newAccount.Id LIMIT 1];
        
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userWithoutMemberships = new User(
            Username = 'nomemberships@test.com',
            Email = 'nomemberships@test.com',
            FirstName = 'No',
            LastName = 'Memberships',
            Alias = 'nomem',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            ContactId = newContact.Id
        );
        insert userWithoutMemberships;
        
        Test.startTest();
        System.runAs(userWithoutMemberships) {
            String result = FetchMembershipInfo.FetchMembershipInfo();
            System.assertEquals('{}', result, 'Should return empty map for user without memberships');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getMembershipTypeOptionsByBrand method
     */
    @IsTest
    static void testGetMembershipTypeOptionsByBrand_Success() {
        User testUser = [SELECT Id FROM User WHERE Email = :TEST_USER_EMAIL LIMIT 1];
        Membership__c testMembership = [SELECT Id FROM Membership__c WHERE Product_ID__c = :Decimal.valueOf(TEST_PRODUCT_ID) LIMIT 1];
        
        Test.startTest();
        System.runAs(testUser) {
            // Set up DMO mock
            List<Memberships__dlm> mockDMORecords = createMockMembershipsDLM();
            Test.setMock(HttpCalloutMock.class, new MembershipsDLMMock(mockDMORecords));
            
            List<FetchMembershipInfo.TypeOption> options = 
                FetchMembershipInfo.getMembershipTypeOptionsByBrand(TEST_BRAND_ID, testMembership.Id);
            
            System.assertEquals(2, options.size(), 'Should return 2 membership type options');
            
            // Verify first option (should be ordered by price DESC)
            FetchMembershipInfo.TypeOption firstOption = options[0];
            System.assertEquals(TEST_PRODUCT_ID, firstOption.id, 'First option should be premium (higher price)');
            System.assertEquals('Premium Monthly', firstOption.name, 'Name should match mock data');
            System.assertEquals('29.99', firstOption.fullPrice, 'Price should match mock data');
            System.assertEquals(3, firstOption.includesList.size(), 'Should have 3 benefits');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getMembershipTypeOptionsByBrand with blank brand
     */
    @IsTest
    static void testGetMembershipTypeOptionsByBrand_BlankBrand() {
        User testUser = [SELECT Id FROM User WHERE Email = :TEST_USER_EMAIL LIMIT 1];
        Membership__c testMembership = [SELECT Id FROM Membership__c WHERE Product_ID__c = :Decimal.valueOf(TEST_PRODUCT_ID) LIMIT 1];
        
        Test.startTest();
        System.runAs(testUser) {
            List<FetchMembershipInfo.TypeOption> options = 
                FetchMembershipInfo.getMembershipTypeOptionsByBrand('', testMembership.Id);
            
            System.assertEquals(0, options.size(), 'Should return empty list for blank brand');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test updateMembershipType method - Upgrade scenario
     */
    @IsTest
    static void testUpdateMembershipType_Upgrade() {
        User testUser = [SELECT Id FROM User WHERE Email = :TEST_USER_EMAIL LIMIT 1];
        Membership__c testMembership = [SELECT Id FROM Membership__c WHERE Product_ID__c = :Decimal.valueOf(TEST_PRODUCT_ID_2) LIMIT 1];
        
        Test.startTest();
        System.runAs(testUser) {
            // Set up DMO mock (TEST_PRODUCT_ID has higher price than TEST_PRODUCT_ID_2)
            List<Memberships__dlm> mockDMORecords = createMockMembershipsDLM();
            Test.setMock(HttpCalloutMock.class, new MembershipsDLMMock(mockDMORecords));
            
            FetchMembershipInfo.updateMembershipType(testMembership.Id, TEST_PRODUCT_ID);
            
            // Verify the update
            Membership__c updatedMembership = [
                SELECT Product_ID__c, Change_Request_Type__c, Change_Request_Time__c 
                FROM Membership__c 
                WHERE Id = :testMembership.Id
            ];
            
            System.assertEquals(Decimal.valueOf(TEST_PRODUCT_ID), updatedMembership.Product_ID__c, 'Product ID should be updated');
            System.assertEquals('Upgrade', updatedMembership.Change_Request_Type__c, 'Should be marked as upgrade');
            System.assertNotEquals(null, updatedMembership.Change_Request_Time__c, 'Change request time should be set');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test updateMembershipType method - Downgrade scenario
     */
    @IsTest
    static void testUpdateMembershipType_Downgrade() {
        User testUser = [SELECT Id FROM User WHERE Email = :TEST_USER_EMAIL LIMIT 1];
        Membership__c testMembership = [SELECT Id FROM Membership__c WHERE Product_ID__c = :Decimal.valueOf(TEST_PRODUCT_ID) LIMIT 1];
        
        Test.startTest();
        System.runAs(testUser) {
            // Set up DMO mock (TEST_PRODUCT_ID_2 has lower price than TEST_PRODUCT_ID)
            List<Memberships__dlm> mockDMORecords = createMockMembershipsDLM();
            Test.setMock(HttpCalloutMock.class, new MembershipsDLMMock(mockDMORecords));
            
            FetchMembershipInfo.updateMembershipType(testMembership.Id, TEST_PRODUCT_ID_2);
            
            // Verify the update
            Membership__c updatedMembership = [
                SELECT Product_ID__c, Change_Request_Type__c, Change_Request_Time__c 
                FROM Membership__c 
                WHERE Id = :testMembership.Id
            ];
            
            System.assertEquals(Decimal.valueOf(TEST_PRODUCT_ID_2), updatedMembership.Product_ID__c, 'Product ID should be updated');
            System.assertEquals('Downgrade', updatedMembership.Change_Request_Type__c, 'Should be marked as downgrade');
            System.assertNotEquals(null, updatedMembership.Change_Request_Time__c, 'Change request time should be set');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test updateMembershipType with invalid parameters
     */
    @IsTest
    static void testUpdateMembershipType_InvalidParameters() {
        User testUser = [SELECT Id FROM User WHERE Email = :TEST_USER_EMAIL LIMIT 1];
        
        Test.startTest();
        System.runAs(testUser) {
            try {
                FetchMembershipInfo.updateMembershipType(null, TEST_PRODUCT_ID);
                System.assert(false, 'Should throw exception for null membership ID');
            } catch (AuraHandledException e) {
                System.assertEquals('Missing required parameters.', e.getMessage(), 'Should throw correct error message');
            }
            
            try {
                Membership__c testMembership = [SELECT Id FROM Membership__c WHERE Product_ID__c = :Decimal.valueOf(TEST_PRODUCT_ID) LIMIT 1];
                FetchMembershipInfo.updateMembershipType(testMembership.Id, '');
                System.assert(false, 'Should throw exception for blank product ID');
            } catch (AuraHandledException e) {
                System.assertEquals('Missing required parameters.', e.getMessage(), 'Should throw correct error message');
            }
        }
        Test.stopTest();
    }
    
    /**
     * @description Test updateMembershipType with unauthorized user
     */
    @IsTest
    static void testUpdateMembershipType_Unauthorized() {
        // Create another user without access to the membership
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User unauthorizedUser = new User(
            Username = 'unauthorized@test.com',
            Email = 'unauthorized@test.com',
            FirstName = 'Unauthorized',
            LastName = 'User',
            Alias = 'unauth',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert unauthorizedUser;
        
        Membership__c testMembership = [SELECT Id FROM Membership__c WHERE Product_ID__c = :Decimal.valueOf(TEST_PRODUCT_ID) LIMIT 1];
        
        Test.startTest();
        System.runAs(unauthorizedUser) {
            try {
                FetchMembershipInfo.updateMembershipType(testMembership.Id, TEST_PRODUCT_ID_2);
                System.assert(false, 'Should throw exception for unauthorized access');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('not authorized'), 'Should throw authorization error');
            }
        }
        Test.stopTest();
    }
    
    /**
     * @description Test cancelMembership method
     */
    @IsTest
    static void testCancelMembership_Success() {
        User testUser = [SELECT Id FROM User WHERE Email = :TEST_USER_EMAIL LIMIT 1];
        Membership__c testMembership = [SELECT Id FROM Membership__c WHERE Product_ID__c = :Decimal.valueOf(TEST_PRODUCT_ID) LIMIT 1];
        
        Test.startTest();
        System.runAs(testUser) {
            FetchMembershipInfo.cancelMembership(testMembership.Id, 'No longer needed');
            
            // Verify the cancellation
            Membership__c cancelledMembership = [
                SELECT Date_Cancellation__c, Cancellation_Reason_Portal__c, Cancellation_Source__c
                FROM Membership__c 
                WHERE Id = :testMembership.Id
            ];
            
            System.assertEquals(Date.today(), cancelledMembership.Date_Cancellation__c, 'Cancellation date should be today');
            System.assertEquals('No longer needed', cancelledMembership.Cancellation_Reason_Portal__c, 'Reason should be set');
            System.assertEquals('Portal', cancelledMembership.Cancellation_Source__c, 'Source should be Portal');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test cancelMembership with null membership ID
     */
    @IsTest
    static void testCancelMembership_NullId() {
        User testUser = [SELECT Id FROM User WHERE Email = :TEST_USER_EMAIL LIMIT 1];
        
        Test.startTest();
        System.runAs(testUser) {
            try {
                FetchMembershipInfo.cancelMembership(null, 'Test reason');
                System.assert(false, 'Should throw exception for null membership ID');
            } catch (AuraHandledException e) {
                System.assertEquals('Missing required parameters.', e.getMessage(), 'Should throw correct error message');
            }
        }
        Test.stopTest();
    }
    
    /**
     * @description Test cancelMembership with unauthorized user
     */
    @IsTest
    static void testCancelMembership_Unauthorized() {
        // Create another user without access to the membership
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User unauthorizedUser = new User(
            Username = 'unauthorized2@test.com',
            Email = 'unauthorized2@test.com',
            FirstName = 'Unauthorized',
            LastName = 'User2',
            Alias = 'unaut2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert unauthorizedUser;
        
        Membership__c testMembership = [SELECT Id FROM Membership__c WHERE Product_ID__c = :Decimal.valueOf(TEST_PRODUCT_ID) LIMIT 1];
        
        Test.startTest();
        System.runAs(unauthorizedUser) {
            try {
                FetchMembershipInfo.cancelMembership(testMembership.Id, 'Test reason');
                System.assert(false, 'Should throw exception for unauthorized access');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('not authorized'), 'Should throw authorization error');
            }
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getLatestSignupDateForUser method
     */
    @IsTest
    static void testGetLatestSignupDateForUser_Success() {
        User testUser = [SELECT Id FROM User WHERE Email = :TEST_USER_EMAIL LIMIT 1];
        
        Test.startTest();
        System.runAs(testUser) {
            String result = FetchMembershipInfo.getLatestSignupDateForUser();
            
            System.assertNotEquals(null, result, 'Should return signup date');
            Date signupDate = Date.valueOf(result);
            System.assertEquals(Date.today().addDays(-30), signupDate, 'Should match the test data signup date');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getLatestSignupDateForUser with user having no contact
     */
    @IsTest
    static void testGetLatestSignupDateForUser_NoContact() {
        // Create user without contact
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userWithoutContact = new User(
            Username = 'nocontact2@test.com',
            Email = 'nocontact2@test.com',
            FirstName = 'No',
            LastName = 'Contact2',
            Alias = 'nocont2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert userWithoutContact;
        
        Test.startTest();
        System.runAs(userWithoutContact) {
            String result = FetchMembershipInfo.getLatestSignupDateForUser();
            System.assertEquals(null, result, 'Should return null for user without contact');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getLatestSignupDateForUser with account having null signup date
     */
    @IsTest
    static void testGetLatestSignupDateForUser_NullSignupDate() {
        // Create account without signup date
        Account accountWithoutSignup = new Account(
            FirstName = 'No',
            LastName = 'Signup Date',
            PersonEmail = 'nosignup@test.com'
        );
        insert accountWithoutSignup;
        
        Contact contactWithoutSignup = [SELECT Id FROM Contact WHERE AccountId = :accountWithoutSignup.Id LIMIT 1];
        
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userWithoutSignup = new User(
            Username = 'nosignup@test.com',
            Email = 'nosignup@test.com',
            FirstName = 'No',
            LastName = 'Signup',
            Alias = 'nosign',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            ContactId = contactWithoutSignup.Id
        );
        insert userWithoutSignup;
        
        Test.startTest();
        System.runAs(userWithoutSignup) {
            String result = FetchMembershipInfo.getLatestSignupDateForUser();
            System.assertEquals(null, result, 'Should return null for account without signup date');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test exception handling in FetchMembershipInfo
     */
    @IsTest
    static void testFetchMembershipInfo_ExceptionHandling() {
        // This test simulates an exception scenario
        // In a real scenario, you might mock a database exception
        User testUser = [SELECT Id FROM User WHERE Email = :TEST_USER_EMAIL LIMIT 1];
        
        Test.startTest();
        System.runAs(testUser) {
            // Delete the user's contact to simulate an exception scenario
            Contact userContact = [SELECT Id FROM Contact WHERE Id = :testUser.ContactId];
            delete userContact;
            
            try {
                String result = FetchMembershipInfo.FetchMembershipInfo();
                // If no exception is thrown, the method should handle gracefully
                System.assertNotEquals(null, result, 'Should handle exceptions gracefully');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error fetching membership info'), 'Should throw proper error message');
            }
        }
        Test.stopTest();
    }
    
    /**
     * @description Test TypeOption wrapper class
     */
    @IsTest
    static void testTypeOptionClass() {
        Test.startTest();
        
        FetchMembershipInfo.TypeOption option = new FetchMembershipInfo.TypeOption();
        option.id = 'TEST_ID';
        option.name = 'Test Name';
        option.fullPrice = '29.99';
        option.description = 'Test Description';
        option.includesList = new List<String>{'Feature1', 'Feature2'};
        option.membershipType = 'Monthly';
        option.productType = 'Subscription';
        
        System.assertEquals('TEST_ID', option.id, 'ID should be set correctly');
        System.assertEquals('Test Name', option.name, 'Name should be set correctly');
        System.assertEquals('29.99', option.fullPrice, 'Price should be set correctly');
        System.assertEquals('Test Description', option.description, 'Description should be set correctly');
        System.assertEquals(2, option.includesList.size(), 'Includes list should have 2 items');
        System.assertEquals('Monthly', option.membershipType, 'Membership type should be set correctly');
        System.assertEquals('Subscription', option.productType, 'Product type should be set correctly');
        
        Test.stopTest();
    }
    
    /**
     * @description Test bulk operations for governor limits
     */
    @IsTest
    static void testBulkOperations() {
        User testUser = [SELECT Id, ContactId FROM User WHERE Email = :TEST_USER_EMAIL LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_CONTACT_EMAIL LIMIT 1];
        
        // Create multiple memberships to test bulk handling
        List<Membership__c> bulkMemberships = new List<Membership__c>();
        for (Integer i = 0; i < 50; i++) {
            bulkMemberships.add(new Membership__c(
                Person_Account_Customer__c = testAccount.Id,
                Product_ID__c = Decimal.valueOf(String.valueOf(10000 + i)),
                Customer_Id__c = 'BULK' + i,
                Active__c = true
            ));
        }
        insert bulkMemberships;
        
        Test.startTest();
        System.runAs(testUser) {
            // Set up DMO mock
            List<Memberships__dlm> mockDMORecords = createMockMembershipsDLM();
            Test.setMock(HttpCalloutMock.class, new MembershipsDLMMock(mockDMORecords));
            
            String result = FetchMembershipInfo.FetchMembershipInfo();
            
            // Verify the method handles bulk data efficiently
            System.assertNotEquals(null, result, 'Should handle bulk data');
            
            Map<Id, Map<String, String>> resultMap = 
                (Map<Id, Map<String, String>>) JSON.deserialize(result, Map<Id, Map<String, String>>.class);
            
            // Should return original 2 test memberships + 50 bulk memberships = 52 total
            System.assertEquals(52, resultMap.size(), 'Should handle all memberships efficiently');
        }
        Test.stopTest();
    }
}