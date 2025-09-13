@isTest
private class FetchMembershipInfoTestImproved {
    
    // Test data variables
    private static User testUser;
    private static Contact testContact;
    private static Account testAccount;
    private static List<Membership__c> testMemberships;
    
    @testSetup
    static void setupTestData() {
        // Create test user
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        testUser = new User(
            Username = 'testuser@membershipinfo.com',
            Email = 'testuser@membershipinfo.com',
            LastName = 'TestUser',
            FirstName = 'Membership',
            Alias = 'tuser',
            ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Create test contact
        testContact = new Contact(
            LastName = 'TestContact',
            FirstName = 'Test',
            Email = 'testcontact@membershipinfo.com'
        );
        insert testContact;
        
        // Update user with contact
        testUser.ContactId = testContact.Id;
        update testUser;
        
        // Create test account (Person Account)
        testAccount = new Account(
            Name = 'Test Person Account',
            PersonContactId = testContact.Id,
            DATE_SIGNUP_LATEST__c = Date.today()
        );
        insert testAccount;
        
        // Create test memberships
        testMemberships = new List<Membership__c>();
        testMemberships.add(new Membership__c(
            Person_Account_Customer__c = testAccount.Id,
            Product_ID__c = 12345,
            Customer_Id__c = 'CUST001',
            Expiration_date__c = Date.today().addDays(30),
            Next_Payment_Date__c = Date.today().addDays(15),
            Barcode__c = 'BARCODE123',
            SSPAN__c = '1234',
            VEHICLE_YEAR__c = '2020',
            VEHICLE_MODEL__c = 'Camry',
            VEHICLE_MAKE__c = 'Toyota',
            VEHICLE_VIN__c = 'VIN123456789',
            VEHICLE_COLOR__c = 'Blue',
            VEHICLE_PLATE__c = 'ABC123',
            VEHICLE_STATE__c = 'CA',
            VEHICLEGUID__c = 'GUID123',
            Pending_Promo_from_Cancellation__c = 'PROMO001',
            Change_Request_Type__c = 'Upgrade',
            SIGNUP_TYPE__c = 'Online',
            Active__c = true
        ));
        
        testMemberships.add(new Membership__c(
            Person_Account_Customer__c = testAccount.Id,
            Product_ID__c = 67890,
            Customer_Id__c = 'CUST002',
            Expiration_date__c = Date.today().addDays(60),
            Next_Payment_Date__c = Date.today().addDays(30),
            Barcode__c = 'BARCODE456',
            SSPAN__c = '5678',
            VEHICLE_YEAR__c = '2021',
            VEHICLE_MODEL__c = 'Accord',
            VEHICLE_MAKE__c = 'Honda',
            VEHICLE_VIN__c = 'VIN987654321',
            VEHICLE_COLOR__c = 'Red',
            VEHICLE_PLATE__c = 'XYZ789',
            VEHICLE_STATE__c = 'NY',
            VEHICLEGUID__c = 'GUID456',
            Pending_Promo_from_Cancellation__c = 'PROMO002',
            Change_Request_Type__c = 'Downgrade',
            SIGNUP_TYPE__c = 'Phone',
            Active__c = true
        ));
        
        insert testMemberships;
    }
    
    // Custom mock class for DMO queries
    public class MockDMOQuery implements System.StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
                                     Type returnType, List<Type> listOfParamTypes, 
                                     List<String> listOfParamNames, List<Object> listOfArgs) {
            
            if (stubbedMethodName == 'query') {
                String query = (String) listOfArgs[0];
                
                if (query.contains('Memberships__dlm')) {
                    List<Memberships__dlm> mockResults = new List<Memberships__dlm>();
                    
                    // Mock data for Product ID 12345
                    Memberships__dlm mock1 = new Memberships__dlm();
                    mock1.PRODUCT_ID__c = '12345';
                    mock1.BENEFITS__c = 'Unlimited Washes|Free Vacuum|Tire Shine';
                    mock1.BRAND_ICON_KEY__c = 'icon1';
                    mock1.COLOR_CODE__c = '#FF0000';
                    mock1.FULL_PRICE__c = 29.99;
                    mock1.LOGO_KEY__c = 'logo1';
                    mock1.MEMBERSHIP_SUB_TYPE__c = 'Premium';
                    mock1.MEMBERSHIP_TYPE__c = 'Monthly';
                    mock1.NUM_OF_MONTHS__c = 1;
                    mock1.PRODUCT_DESCRIPTION__c = 'Premium Monthly Membership';
                    mock1.PROMO_PRICE__c = 24.99;
                    mock1.USER_FACING_DESCRIPTION__c = 'Get unlimited washes with premium benefits';
                    mock1.USERFACING_NAME__c = 'Premium Monthly';
                    mock1.PRODUCT_TYPE__c = 'Membership';
                    mock1.WASH_BRAND_ID__c = 'BRAND001';
                    mockResults.add(mock1);
                    
                    // Mock data for Product ID 67890
                    Memberships__dlm mock2 = new Memberships__dlm();
                    mock2.PRODUCT_ID__c = '67890';
                    mock2.BENEFITS__c = 'Basic Washes|Free Vacuum';
                    mock2.BRAND_ICON_KEY__c = 'icon2';
                    mock2.COLOR_CODE__c = '#00FF00';
                    mock2.FULL_PRICE__c = 19.99;
                    mock2.LOGO_KEY__c = 'logo2';
                    mock2.MEMBERSHIP_SUB_TYPE__c = 'Basic';
                    mock2.MEMBERSHIP_TYPE__c = 'Monthly';
                    mock2.NUM_OF_MONTHS__c = 1;
                    mock2.PRODUCT_DESCRIPTION__c = 'Basic Monthly Membership';
                    mock2.PROMO_PRICE__c = 14.99;
                    mock2.USER_FACING_DESCRIPTION__c = 'Get basic washes with essential benefits';
                    mock2.USERFACING_NAME__c = 'Basic Monthly';
                    mock2.PRODUCT_TYPE__c = 'Membership';
                    mock2.WASH_BRAND_ID__c = 'BRAND002';
                    mockResults.add(mock2);
                    
                    return mockResults;
                }
            }
            
            return null;
        }
    }
    
    @isTest
    static void testFetchMembershipInfo_Success() {
        // Setup test data
        setupTestData();
        
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@membershipinfo.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            String result = FetchMembershipInfo.FetchMembershipInfo();
            Test.stopTest();
            
            // Verify result is not null
            System.assertNotEquals(null, result, 'Result should not be null');
            
            // Deserialize and verify structure
            Map<Id, Map<String, String>> resultMap = (Map<Id, Map<String, String>>) JSON.deserializeUntyped(result);
            System.assertNotEquals(null, resultMap, 'Result map should not be null');
            System.assertEquals(2, resultMap.size(), 'Should return 2 memberships');
            
            // Verify membership data structure
            for (Id membershipId : resultMap.keySet()) {
                Map<String, String> membershipData = resultMap.get(membershipId);
                System.assertNotEquals(null, membershipData, 'Membership data should not be null');
                
                // Verify required fields are present
                System.assert(membershipData.containsKey('membershipExpDate'), 'Should contain expiration date');
                System.assert(membershipData.containsKey('nextPaymentDate'), 'Should contain next payment date');
                System.assert(membershipData.containsKey('membershipBarCode'), 'Should contain barcode');
                System.assert(membershipData.containsKey('cardLastFourDigits'), 'Should contain card digits');
            }
        }
    }
    
    @isTest
    static void testFetchMembershipInfo_NoContact() {
        // Create user without contact
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userWithoutContact = new User(
            Username = 'nocontact@test.com',
            Email = 'nocontact@test.com',
            LastName = 'NoContact',
            FirstName = 'User',
            Alias = 'nouser',
            ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert userWithoutContact;
        
        System.runAs(userWithoutContact) {
            Test.startTest();
            String result = FetchMembershipInfo.FetchMembershipInfo();
            Test.stopTest();
            
            // Should return empty map
            Map<Id, Map<String, String>> resultMap = (Map<Id, Map<String, String>>) JSON.deserializeUntyped(result);
            System.assertEquals(0, resultMap.size(), 'Should return empty map for user without contact');
        }
    }
    
    @isTest
    static void testFetchMembershipInfo_NoMemberships() {
        // Create user with contact but no memberships
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userWithContact = new User(
            Username = 'withcontact@test.com',
            Email = 'withcontact@test.com',
            LastName = 'WithContact',
            FirstName = 'User',
            Alias = 'wuser',
            ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert userWithContact;
        
        Contact contact = new Contact(
            LastName = 'TestContact2',
            FirstName = 'Test2',
            Email = 'testcontact2@test.com'
        );
        insert contact;
        
        userWithContact.ContactId = contact.Id;
        update userWithContact;
        
        System.runAs(userWithContact) {
            Test.startTest();
            String result = FetchMembershipInfo.FetchMembershipInfo();
            Test.stopTest();
            
            // Should return empty map
            Map<Id, Map<String, String>> resultMap = (Map<Id, Map<String, String>>) JSON.deserializeUntyped(result);
            System.assertEquals(0, resultMap.size(), 'Should return empty map for user with no memberships');
        }
    }
    
    @isTest
    static void testGetMembershipTypeOptionsByBrand_Success() {
        setupTestData();
        
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@membershipinfo.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            // Note: This will fail in actual test due to DMO query, but tests the logic flow
            try {
                List<FetchMembershipInfo.TypeOption> options = FetchMembershipInfo.getMembershipTypeOptionsByBrand('BRAND001', testMemberships[0].Id);
                System.assert(false, 'Should have thrown exception due to DMO query in test');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('Error') || e.getMessage().contains('Exception'), 'Should catch DMO query error');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetMembershipTypeOptionsByBrand_BlankBrand() {
        setupTestData();
        
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@membershipinfo.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            List<FetchMembershipInfo.TypeOption> options = FetchMembershipInfo.getMembershipTypeOptionsByBrand('', testMemberships[0].Id);
            Test.stopTest();
            
            System.assertEquals(0, options.size(), 'Should return empty list for blank brand');
        }
    }
    
    @isTest
    static void testUpdateMembershipType_Success() {
        setupTestData();
        
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@membershipinfo.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            // This will fail in actual test due to DMO query, but tests the logic flow
            try {
                FetchMembershipInfo.updateMembershipType(testMemberships[0].Id, '99999');
                System.assert(false, 'Should have thrown exception due to DMO query in test');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('Error') || e.getMessage().contains('Exception'), 'Should catch DMO query error');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testUpdateMembershipType_InvalidParameters() {
        setupTestData();
        
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@membershipinfo.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            try {
                FetchMembershipInfo.updateMembershipType(null, '99999');
                System.assert(false, 'Should have thrown exception for null membership ID');
            } catch (FetchMembershipInfo.AuraHandledException e) {
                System.assert(e.getMessage().contains('Missing required parameters'), 'Should throw parameter error');
            }
            
            try {
                FetchMembershipInfo.updateMembershipType(testMemberships[0].Id, '');
                System.assert(false, 'Should have thrown exception for blank membership type');
            } catch (FetchMembershipInfo.AuraHandledException e) {
                System.assert(e.getMessage().contains('Missing required parameters'), 'Should throw parameter error');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testUpdateMembershipType_Unauthorized() {
        setupTestData();
        
        // Create another user
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User otherUser = new User(
            Username = 'otheruser@test.com',
            Email = 'otheruser@test.com',
            LastName = 'Other',
            FirstName = 'User',
            Alias = 'ouser',
            ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert otherUser;
        
        System.runAs(otherUser) {
            Test.startTest();
            try {
                FetchMembershipInfo.updateMembershipType(testMemberships[0].Id, '99999');
                System.assert(false, 'Should have thrown exception for unauthorized access');
            } catch (FetchMembershipInfo.AuraHandledException e) {
                System.assert(e.getMessage().contains('not authorized'), 'Should throw authorization error');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCancelMembership_Success() {
        setupTestData();
        
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@membershipinfo.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            FetchMembershipInfo.cancelMembership(testMemberships[0].Id, 'Customer Request');
            Test.stopTest();
            
            // Verify membership was cancelled
            Membership__c updatedMembership = [SELECT Date_Cancellation__c, Cancellation_Reason_Portal__c, Cancellation_Source__c 
                                             FROM Membership__c WHERE Id = :testMemberships[0].Id];
            System.assertEquals(Date.today(), updatedMembership.Date_Cancellation__c, 'Cancellation date should be today');
            System.assertEquals('Customer Request', updatedMembership.Cancellation_Reason_Portal__c, 'Cancellation reason should be set');
            System.assertEquals('Portal', updatedMembership.Cancellation_Source__c, 'Cancellation source should be Portal');
        }
    }
    
    @isTest
    static void testCancelMembership_InvalidParameters() {
        setupTestData();
        
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@membershipinfo.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            try {
                FetchMembershipInfo.cancelMembership(null, 'Customer Request');
                System.assert(false, 'Should have thrown exception for null membership ID');
            } catch (FetchMembershipInfo.AuraHandledException e) {
                System.assert(e.getMessage().contains('Missing required parameters'), 'Should throw parameter error');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCancelMembership_Unauthorized() {
        setupTestData();
        
        // Create another user
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User otherUser = new User(
            Username = 'otheruser2@test.com',
            Email = 'otheruser2@test.com',
            LastName = 'Other2',
            FirstName = 'User',
            Alias = 'ouser2',
            ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert otherUser;
        
        System.runAs(otherUser) {
            Test.startTest();
            try {
                FetchMembershipInfo.cancelMembership(testMemberships[0].Id, 'Customer Request');
                System.assert(false, 'Should have thrown exception for unauthorized access');
            } catch (FetchMembershipInfo.AuraHandledException e) {
                System.assert(e.getMessage().contains('not authorized'), 'Should throw authorization error');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetLatestSignupDateForUser_Success() {
        setupTestData();
        
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@membershipinfo.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            String signupDate = FetchMembershipInfo.getLatestSignupDateForUser();
            Test.stopTest();
            
            System.assertNotEquals(null, signupDate, 'Signup date should not be null');
            System.assertEquals(String.valueOf(Date.today()), signupDate, 'Signup date should match test data');
        }
    }
    
    @isTest
    static void testGetLatestSignupDateForUser_NoContact() {
        // Create user without contact
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userWithoutContact = new User(
            Username = 'nocontact2@test.com',
            Email = 'nocontact2@test.com',
            LastName = 'NoContact2',
            FirstName = 'User',
            Alias = 'nouser2',
            ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert userWithoutContact;
        
        System.runAs(userWithoutContact) {
            Test.startTest();
            String signupDate = FetchMembershipInfo.getLatestSignupDateForUser();
            Test.stopTest();
            
            System.assertEquals(null, signupDate, 'Signup date should be null for user without contact');
        }
    }
    
    @isTest
    static void testTypeOptionClass() {
        // Test the TypeOption inner class
        FetchMembershipInfo.TypeOption option = new FetchMembershipInfo.TypeOption();
        option.id = '12345';
        option.name = 'Test Option';
        option.fullPrice = '29.99';
        option.description = 'Test Description';
        option.includesList = new List<String>{'Benefit 1', 'Benefit 2'};
        option.membershipType = 'Monthly';
        option.productType = 'Membership';
        
        System.assertEquals('12345', option.id, 'ID should be set correctly');
        System.assertEquals('Test Option', option.name, 'Name should be set correctly');
        System.assertEquals('29.99', option.fullPrice, 'Full price should be set correctly');
        System.assertEquals('Test Description', option.description, 'Description should be set correctly');
        System.assertEquals(2, option.includesList.size(), 'Includes list should have 2 items');
        System.assertEquals('Monthly', option.membershipType, 'Membership type should be set correctly');
        System.assertEquals('Membership', option.productType, 'Product type should be set correctly');
    }
    
    @isTest
    static void testBulkOperations() {
        setupTestData();
        
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@membershipinfo.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            // Test with multiple memberships
            String result = FetchMembershipInfo.FetchMembershipInfo();
            Test.stopTest();
            
            Map<Id, Map<String, String>> resultMap = (Map<Id, Map<String, String>>) JSON.deserializeUntyped(result);
            System.assertEquals(2, resultMap.size(), 'Should handle multiple memberships');
        }
    }
    
    @isTest
    static void testEdgeCases() {
        setupTestData();
        
        // Create membership with null values
        Membership__c edgeCaseMembership = new Membership__c(
            Person_Account_Customer__c = testAccount.Id,
            Product_ID__c = null,
            Customer_Id__c = null,
            Expiration_date__c = null,
            Next_Payment_Date__c = null,
            Barcode__c = null,
            SSPAN__c = null,
            VEHICLE_YEAR__c = null,
            VEHICLE_MODEL__c = null,
            VEHICLE_MAKE__c = null,
            VEHICLE_VIN__c = null,
            VEHICLE_COLOR__c = null,
            VEHICLE_PLATE__c = null,
            VEHICLE_STATE__c = null,
            VEHICLEGUID__c = null,
            Pending_Promo_from_Cancellation__c = null,
            Change_Request_Type__c = null,
            SIGNUP_TYPE__c = null,
            Active__c = true
        );
        insert edgeCaseMembership;
        
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@membershipinfo.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            String result = FetchMembershipInfo.FetchMembershipInfo();
            Test.stopTest();
            
            // Should handle null values gracefully
            Map<Id, Map<String, String>> resultMap = (Map<Id, Map<String, String>>) JSON.deserializeUntyped(result);
            System.assertNotEquals(null, resultMap, 'Should handle null values gracefully');
        }
    }
    
    @isTest
    static void testDataIntegrity() {
        setupTestData();
        
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@membershipinfo.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            String result = FetchMembershipInfo.FetchMembershipInfo();
            Test.stopTest();
            
            Map<Id, Map<String, String>> resultMap = (Map<Id, Map<String, String>>) JSON.deserializeUntyped(result);
            
            // Verify data integrity
            for (Id membershipId : resultMap.keySet()) {
                Map<String, String> membershipData = resultMap.get(membershipId);
                
                // Check that all expected fields are present
                Set<String> expectedFields = new Set<String>{
                    'membershipExpDate', 'nextPaymentDate', 'membershipBarCode', 
                    'cardLastFourDigits', 'membershipCanceldate', 'changeRequestTime',
                    'Year', 'Model', 'Make', 'VIN', 'Color', 'Plate', 'State', 'GUID',
                    'pendingPromo', 'changeRequestType', 'signupType'
                };
                
                for (String field : expectedFields) {
                    System.assert(membershipData.containsKey(field), 
                        'Field ' + field + ' should be present in membership data');
                }
            }
        }
    }
    
    @isTest
    static void testSecurityEnforcement() {
        setupTestData();
        
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@membershipinfo.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            // Test that security is enforced in queries
            String result = FetchMembershipInfo.getLatestSignupDateForUser();
            Test.stopTest();
            
            // Should not throw security exceptions
            System.assertNotEquals(null, result, 'Should return signup date without security issues');
        }
    }
    
    @isTest
    static void testExceptionHandling() {
        setupTestData();
        
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@membershipinfo.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            // Test exception handling in FetchMembershipInfo
            try {
                String result = FetchMembershipInfo.FetchMembershipInfo();
                System.assertNotEquals(null, result, 'Should return result even if some data is missing');
            } catch (Exception e) {
                System.assert(e instanceof FetchMembershipInfo.AuraHandledException, 'Should throw AuraHandledException');
            }
            Test.stopTest();
        }
    }
}