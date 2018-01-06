/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 1999-2000 The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution,
 *    if any, must include the following acknowledgment:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowledgment may appear in the software itself,
 *    if and wherever such third-party acknowledgments normally appear.
 *
 * 4. The names "Xerces" and "Apache Software Foundation" must
 *    not be used to endorse or promote products derived from this
 *    software without prior written permission. For written
 *    permission, please contact apache\@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache",
 *    nor may "Apache" appear in their name, without prior written
 *    permission of the Apache Software Foundation.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation, and was
 * originally based on software copyright (c) 1999, International
 * Business Machines, Inc., http://www.ibm.com .  For more information
 * on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */

/*
 * $Log: XMLString.hpp,v $
 * Revision 1.1.1.1  2000/09/20 20:40:40  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.13  2000/04/12 18:42:15  roddey
 * Improved docs in terms of what 'max chars' means in the method
 * parameters.
 *
 * Revision 1.12  2000/04/06 19:42:51  rahulj
 * Clarified how big the target buffer should be in the API
 * documentation.
 *
 * Revision 1.11  2000/03/23 01:02:38  roddey
 * Updates to the XMLURL class to correct a lot of parsing problems
 * and to add support for the port number. Updated the URL tests
 * to test some of this new stuff.
 *
 * Revision 1.10  2000/03/20 23:00:46  rahulj
 * Moved the inline definition of stringLen before the first
 * use. This satisfied the HP CC compiler.
 *
 * Revision 1.9  2000/03/02 19:54:49  roddey
 * This checkin includes many changes done while waiting for the
 * 1.1.0 code to be finished. I can't list them all here, but a list is
 * available elsewhere.
 *
 * Revision 1.8  2000/02/24 20:05:26  abagchi
 * Swat for removing Log from API docs
 *
 * Revision 1.7  2000/02/16 18:51:52  roddey
 * Fixed some facts in the docs and reformatted the docs to stay within
 * a reasonable line width.
 *
 * Revision 1.6  2000/02/16 17:07:07  abagchi
 * Added API docs
 *
 * Revision 1.5  2000/02/06 07:48:06  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.4  2000/01/12 00:16:23  roddey
 * Changes to deal with multiply nested, relative pathed, entities and to deal
 * with the new URL class changes.
 *
 * Revision 1.3  1999/12/18 00:18:10  roddey
 * More changes to support the new, completely orthagonal support for
 * intrinsic encodings.
 *
 * Revision 1.2  1999/12/15 19:41:28  roddey
 * Support for the new transcoder system, where even intrinsic encodings are
 * done via the same transcoder abstraction as external ones.
 *
 * Revision 1.1.1.1  1999/11/09 01:05:52  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:45:21  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */

#if !defined(XMLSTRING_HPP)
#define XMLSTRING_HPP

#include <util/XercesDefs.hpp>

class XMLLCPTranscoder;

/**
  * Class for representing native character strings and handling common string
  * operations
  *
  * This class is Unicode compliant. This class is designed primarily
  * for internal use, but due to popular demand, it is being made
  * publicly available. Users of this class must understand that this
  * is not an officially supported class. All public methods of this
  * class are <i>static functions</i>.
  *
  */
class XMLUTIL_EXPORT XMLString
{
public:
    /* Static methods for native character mode string manipulation */
    /** @name Conversion functions */
    //@{

    /** Converts binary data to a text string based a given radix
      *
      * @param toFormat The beginning of the input string to convert
      * @param toFill The buffer that will hold the output on return. The
      *        size of this buffer should at least be 'maxChars + 1'.
      * @param maxChars The maximum number of output characters that can be
      *         accepted. If the result will not fit, it is an error.
      * @param radix The radix of the input data, based on which the conversion
      * will be done
      */
    static void binToText
    (
        const   unsigned int    toFormat
        ,       char* const     toFill
        , const unsigned int    maxChars
        , const unsigned int    radix
    );

    /** Converts binary data to a text string based a given radix
      *
      * @param toFormat The beginning of the input string to convert
      * @param toFill The buffer that will hold the output on return. The
      *        size of this buffer should at least be 'maxChars + 1'.
      * @param maxChars The maximum number of output characters that can be
      *         accepted. If the result will not fit, it is an error.
      * @param radix The radix of the input data, based on which the conversion
      * will be done
      */
    static void binToText
    (
        const   unsigned int    toFormat
        ,       XMLCh* const    toFill
        , const unsigned int    maxChars
        , const unsigned int    radix
    );

    /** Converts binary data to a text string based a given radix
      *
      * @param toFormat The beginning of the input string to convert
      * @param toFill The buffer that will hold the output on return. The
      *        size of this buffer should at least be 'maxChars + 1'.
      * @param maxChars The maximum number of output characters that can be
      *         accepted. If the result will not fit, it is an error.
      * @param radix The radix of the input data, based on which the conversion
      * will be done
      */
    static void binToText
    (
        const   unsigned long   toFormat
        ,       char* const     toFill
        , const unsigned int    maxChars
        , const unsigned int    radix
    );

    /** Converts binary data to a text string based a given radix
      *
      * @param toFormat The beginning of the input string to convert
      * @param toFill The buffer that will hold the output on return. The
      *        size of this buffer should at least be 'maxChars + 1'.
      * @param maxChars The maximum number of output characters that can be
      *         accepted. If the result will not fit, it is an error.
      * @param radix The radix of the input data, based on which the conversion
      * will be done
      */
    static void binToText
    (
        const   unsigned long   toFormat
        ,       XMLCh* const    toFill
        , const unsigned int    maxChars
        , const unsigned int    radix
    );

    /** Converts binary data to a text string based a given radix
      *
      * @param toFormat The beginning of the input string to convert
      * @param toFill The buffer that will hold the output on return. The
      *        size of this buffer should at least be 'maxChars + 1'.
      * @param maxChars The maximum number of output characters that can be
      *         accepted. If the result will not fit, it is an error.
      * @param radix The radix of the input data, based on which the conversion
      * will be done
      */
    static void binToText
    (
        const   long            toFormat
        ,       char* const     toFill
        , const unsigned int    maxChars
        , const unsigned int    radix
    );

    /** Converts binary data to a text string based a given radix
      *
      * @param toFormat The beginning of the input string to convert
      * @param toFill The buffer that will hold the output on return. The
      *        size of this buffer should at least be 'maxChars + 1'.
      * @param maxChars The maximum number of output characters that can be
      *         accepted. If the result will not fit, it is an error.
      * @param radix The radix of the input data, based on which the conversion
      * will be done
      */
    static void binToText
    (
        const   long            toFormat
        ,       XMLCh* const    toFill
        , const unsigned int    maxChars
        , const unsigned int    radix
    );

    /** Converts binary data to a text string based a given radix
      *
      * @param toFormat The beginning of the input string to convert
      * @param toFill The buffer that will hold the output on return. The
      *        size of this buffer should at least be 'maxChars + 1'.
      * @param maxChars The maximum number of output characters that can be
      *         accepted. If the result will not fit, it is an error.
      * @param radix The radix of the input data, based on which the conversion
      * will be done
      */
    static void binToText
    (
        const   int             toFormat
        ,       char* const     toFill
        , const unsigned int    maxChars
        , const unsigned int    radix
    );

    /** Converts binary data to a text string based a given radix
      *
      * @param toFormat The beginning of the input string to convert
      * @param toFill The buffer that will hold the output on return. The
      *        size of this buffer should at least be 'maxChars + 1'.
      * @param maxChars The maximum number of output characters that can be
      *         accepted. If the result will not fit, it is an error.
      * @param radix The radix of the input data, based on which the conversion
      * will be done
      */
    static void binToText
    (
        const   int             toFormat
        ,       XMLCh* const    toFill
        , const unsigned int    maxChars
        , const unsigned int    radix
    );

    /**
      * Converts a string of decimal chars to a binary value
      *
      * Note that leading and trailng whitespace is legal and will be ignored
      * but the remainder must be all decimal digits.
      *
      * @param toConvert The string of digits to convert
      * @param toFill    The unsigned int value to fill with the converted
      *                  value.
      */
    static bool textToBin
    (
        const   XMLCh* const    toConvert
        ,       unsigned int&   toFill
    );
    //@}

    /** @name String concatenation functions */
    //@{
    /** Concatenates two strings.
      *
      * <code>catString</code> appends <code>src</code> to <code>target</code> and
      * terminates the resulting string with a null character. The initial character
      * of <code>src</code> overwrites the terminating character of <code>target
      * </code>.
      *
      * No overflow checking is performed when strings are copied or appended.
      * The behavior of <code>catString</code> is undefined if source and
      * destination strings overlap.
      *
      * @param target Null-terminated destination string
      * @param src Null-terminated source string
      */
    static void catString
    (
                char* const     target
        , const char* const     src
    );

    /** Concatenates two strings.
      *
      * <code>catString</code> appends <code>src</code> to <code>target</code> and
      * terminates the resulting string with a null character. The initial character of
      * <code>src</code> overwrites the terminating character of <code>target</code>.
      * No overflow checking is performed when strings are copied or appended.
      * The behavior of <code>catString</code> is undefined if source and destination
      * strings overlap.
      *
      *    @param target Null-terminated destination string
      * @param src Null-terminated source string
      */
    static void catString
    (
                XMLCh* const    target
        , const XMLCh* const    src
    );
    //@}

    /** @name String comparison functions */
    //@{
    /** Lexicographically compares lowercase versions of <code>str1</code> and
      * <code>str2</code> and returns a value indicating their relationship.
      * @param str1 Null-terminated string to compare
      * @param str2 Null-terminated string to compare
      *
      * @return The return value indicates the relation of <code>str1</code> to
      * <code>str2</code> as follows
      *  Less than 0 means <code>str1</code> is less than <code>str2</code>
      *  Equal to 0 means <code>str1</code> is identical to <code>str2</code> 
      *  Greater than 0 means <code>str1</code> is more than <code>str2</code> 
      */
    static int compareIString
    (
        const   char* const     str1
        , const char* const     str2
    );

    /** Lexicographically compares lowercase versions of <code>str1</code> and
      * <code>str2</code> and returns a value indicating their relationship.
      * @param str1 Null-terminated string to compare
      * @param str2 Null-terminated string to compare
      * @return The return value indicates the relation of <code>str1</code> to
      * <code>str2</code> as follows
      *  Less than 0 means <code>str1</code> is less than <code>str2</code>
      *  Equal to 0 means <code>str1</code> is identical to <code>str2</code> 
      *  Greater than 0 means <code>str1</code> is more than <code>str2</code> 
      */
    static int compareIString
    (
        const   XMLCh* const    str1
        , const XMLCh* const    str2
    );


    /** Lexicographically compares, at most, the first count characters in
      * <code>str1</code> and <code>str2</code> and returns a value indicating the
      * relationship between the substrings.
      * @param str1 Null-terminated string to compare
      * @param str2 Null-terminated string to compare
      * @param count The number of characters to compare
      *
      * @return The return value indicates the relation of <code>str1</code> to
      * <code>str2</code> as follows
      *  Less than 0 means <code>str1</code> is less than <code>str2</code>
      *  Equal to 0 means <code>str1</code> is identical to <code>str2</code> 
      *  Greater than 0 means <code>str1</code> is more than <code>str2</code> 
      */
    static int compareNString
    (
        const   char* const     str1
        , const char* const     str2
        , const unsigned int    count
    );

    /** Lexicographically compares, at most, the first count characters in
      * <code>str1</code> and <code>str2</code> and returns a value indicating
      * the relationship between the substrings.
      * @param str1 Null-terminated string to compare
      * @param str2 Null-terminated string to compare
      * @param count The number of characters to compare
      *
      * @return The return value indicates the relation of <code>str1</code> to
      * <code>str2</code> as follows
      *  Less than 0 means <code>str1</code> is less than <code>str2</code>
      *  Equal to 0 means <code>str1</code> is identical to <code>str2</code> 
      *  Greater than 0 means <code>str1</code> is more than <code>str2</code> 
      */
    static int compareNString
    (
        const   XMLCh* const    str1
        , const XMLCh* const    str2
        , const unsigned int    count
    );


    /** Lexicographically compares, at most, the first count characters in
      * <code>str1</code> and <code>str2</code> without regard to case and
      * returns a value indicating the relationship between the substrings.
      *
      * @param str1 Null-terminated string to compare
      * @param str2 Null-terminated string to compare
      * @param count The number of characters to compare
      * @return The return value indicates the relation of <code>str1</code> to
      * <code>str2</code> as follows
      *  Less than 0 means <code>str1</code> is less than <code>str2</code>
      *  Equal to 0 means <code>str1</code> is identical to <code>str2</code> 
      *  Greater than 0 means <code>str1</code> is more than <code>str2</code> 
      */
    static int compareNIString
    (
        const   char* const     str1
        , const char* const     str2
        , const unsigned int    count
    );

    /** Lexicographically compares, at most, the first count characters in
      * <code>str1</code> and <code>str2</code> without regard to case and
      * returns a value indicating the relationship between the substrings.
      *
      * @param str1 Null-terminated string to compare
      * @param str2 Null-terminated string to compare
      * @param count The number of characters to compare
      *
      * @return The return value indicates the relation of <code>str1</code> to
      * <code>str2</code> as follows
      *  Less than 0 means <code>str1</code> is less than <code>str2</code>
      *  Equal to 0 means <code>str1</code> is identical to <code>str2</code> 
      *  Greater than 0 means <code>str1</code> is more than <code>str2</code> 
      */
    static int compareNIString
    (
        const   XMLCh* const    str1
        , const XMLCh* const    str2
        , const unsigned int    count
    );

    /** Lexicographically compares <code>str1</code> and <code>str2</code> and
      * returns a value indicating their relationship.
      *
      * @param str1 Null-terminated string to compare
      * @param str2 Null-terminated string to compare
      *
      * @return The return value indicates the relation of <code>str1</code> to
      * <code>str2</code> as follows
      *  Less than 0 means <code>str1</code> is less than <code>str2</code>
      *  Equal to 0 means <code>str1</code> is identical to <code>str2</code> 
      *  Greater than 0 means <code>str1</code> is more than <code>str2</code> 
      */
    static int compareString
    (
        const   char* const     str1
        , const char* const     str2
    );

    /** Lexicographically compares <code>str1</code> and <code>str2</code> and
      * returns a value indicating their relationship.
      *
      * @param str1 Null-terminated string to compare
      * @param str2 Null-terminated string to compare
      * @return The return value indicates the relation of <code>str1</code> to
      * <code>str2</code> as follows
      *  Less than 0 means <code>str1</code> is less than <code>str2</code>
      *  Equal to 0 means <code>str1</code> is identical to <code>str2</code> 
      *  Greater than 0 means <code>str1</code> is more than <code>str2</code> 
      */
    static int compareString
    (
        const   XMLCh* const    str1
        , const XMLCh* const    str2
    );
    //@}

    /** @name String copy functions */
    //@{
    /** Copies <code>src</code>, including the terminating null character, to the
      * location specified by <code>target</code>.
      *
      * No overflow checking is performed when strings are copied or appended.
      * The behavior of strcpy is undefined if the source and destination strings
      * overlap.
      *
      * @param target Destination string
      * @param src Null-terminated source string
      */
    static void copyString
    (
                char* const     target
        , const char* const     src
    );

    /** Copies <code>src</code>, including the terminating null character, to
      *   the location specified by <code>target</code>.
      *
      * No overflow checking is performed when strings are copied or appended.
      * The behavior of <code>copyString</code> is undefined if the source and
      * destination strings overlap.
      *
      * @param target Destination string
      * @param src Null-terminated source string
      */
    static void copyString
    (
                XMLCh* const    target
        , const XMLCh* const    src
    );

    /** Copies <code>src</code>, upto a fixed number of characters, to the
      * location specified by <code>target</code>.
      *
      * No overflow checking is performed when strings are copied or appended.
      * The behavior of <code>copyNString</code> is undefined if the source and
      * destination strings overlap.
      *
      * @param target Destination string. The size of the buffer should
      *        atleast be 'maxChars + 1'.
      * @param src Null-terminated source string
      * @param maxChars The maximum number of characters to copy
      */
    static bool copyNString
    (
                XMLCh* const    target
        , const XMLCh* const    src
        , const unsigned int    maxChars
    );
    //@}

    /** @name Hash functions */
    //@{
    /** Hashes a string given a modulus
      *
      * @param toHash The string to hash
      * @param hashModulus The divisor to be used for hashing
      * @return Returns the hash value
      */
    static unsigned int hash
    (
        const   char* const     tohash
        , const unsigned int    hashModulus
    );

    /** Hashes a string given a modulus
      *
      * @param toHash The string to hash
      * @param hashModulus The divisor to be used for hashing
      * @return Returns the hash value
      */
    static unsigned int hash
    (
        const   XMLCh* const    toHash
        , const unsigned int    hashModulus
    );

    /** Hashes a string given a modulus taking a maximum number of characters
      * as the limit
      *
      * @param toHash The string to hash
      * @param numChars The maximum number of characters to consider for hashing
      * @param hashModulus The divisor to be used for hashing
      *
      * @return Returns the hash value
      */
    static unsigned int hashN
    (
        const   XMLCh* const    toHash
        , const unsigned int    numChars
        , const unsigned int    hashModulus
    );

    //@}

    /** @name Search functions */
    //@{
    /**
      * Provides the index of the first occurance of a character within a string
      *
      * @param toSearch The string to search
      * @param ch The character to search within the string
      * @return If found, returns the index of the character within the string,
      * else returns -1.
      */
    static int indexOf(const char* const toSearch, const char ch);

    /**
      * Provides the index of the first occurance of a character within a string
      *
      * @param toSearch The string to search
      * @param ch The character to search within the string
      * @return If found, returns the index of the character within the string,
      * else returns -1.
      */
    static int indexOf(const XMLCh* const toSearch, const XMLCh ch);

    /**
      * Provides the index of the last occurance of a character within a string
      *
      * @param toSearch The string to search
      * @param ch The character to search within the string
      * @return If found, returns the index of the character within the string,
      * else returns -1.
      */
    static int lastIndexOf(const char* const toSearch, const char ch);

    /**
      * Provides the index of the last occurance of a character within a string
      *
      * @param toSearch The string to search
      * @param ch The character to search within the string
      * @return If found, returns the index of the character within the string,
      * else returns -1.
      */
    static int lastIndexOf(const XMLCh* const toSearch, const XMLCh ch);

    /**
      * Provides the index of the last occurance of a character within a string
      * starting backward from a given index
      *
      * @param toSearch The string to search
      * @param chToFInd The character to search within the string
      * @param fromIndex The index to start backward search from
      * @return If found, returns the index of the character within the string,
      * else returns -1.
      */
    static int lastIndexOf
    (
        const   char* const     toSearch
        , const char            chToFind
        , const unsigned int    fromIndex
    );

    /**
      * Provides the index of the last occurance of a character within a string
      * starting backward from a given index
      *
      * @param toSearch The string to search
      * @param chToFInd The character to search within the string
      * @param fromIndex The index to start backward search from
      * @return If found, returns the index of the character within the string,
      * else returns -1.
      */
    static int lastIndexOf
    (
        const   XMLCh* const    toSearch
        , const XMLCh           ch
        , const unsigned int    fromIndex
    );
    //@}

    /** @name Fixed size string movement */
    //@{
    /** Moves X number of chars
      * @param targetStr The string to copy the chars to
      * @param srcStr The string to copy the chars from
      * @param count The number of chars to move
      */
    static void moveChars
    (
                XMLCh* const    targetStr
        , const XMLCh* const    srcStr
        , const unsigned int    count
    );

    //@}

    /** @name Replication function */
    //@{
    /** Replicates a string
      * @param toRep The string to replicate
      * @return Returns a pointer to the replicated string
      */
    static char* replicate(const char* const toRep);

    /** Replicates a string
      * @param toRep The string to replicate
      * @return Returns a pointer to the replicated string
      */
    static XMLCh* replicate(const XMLCh* const toRep);

    //@}

    /** @name String query function */
    //@{
    /** Tells if the sub-string appears within a string at the beginning
      * @param toTest The string to test
      * @param prefix The sub-string that needs to be checked
      * @return Returns true if the sub-string was found at the beginning of
      * <code>toTest</code>, else false
      */
    static bool startsWith
    (
        const   char* const     toTest
        , const char* const     prefix
    );

    /** Tells if the sub-string appears within a string at the beginning
      * @param toTest The string to test
      * @param prefix The sub-string that needs to be checked
      * @return Returns true if the sub-string was found at the beginning of
      * <code>toTest</code>, else false
      */
    static bool startsWith
    (
        const   XMLCh* const    toTest
        , const XMLCh* const    prefix
    );

    /** Tells if the sub-string appears within a string at the beginning
      * without regard to case
      *
      * @param toTest The string to test
      * @param prefix The sub-string that needs to be checked
      * @return Returns true if the sub-string was found at the beginning of
      * <code>toTest</code>, else false
      */
    static bool startsWithI
    (
        const   char* const     toTest
        , const char* const     prefix
    );

    /** Tells if the sub-string appears within a string at the beginning
      * without regard to case
      *
      * @param toTest The string to test
      * @param prefix The sub-string that needs to be checked
      *
      * @return Returns true if the sub-string was found at the beginning
      * of <code>toTest</code>, else false
      */
    static bool startsWithI
    (
        const   XMLCh* const    toTest
        , const XMLCh* const    prefix
    );

    /** Tells if a string has any occurance of another string within itself
      * @param toSearch The string to be searched
      * @param searchList The sub-string to be searched within the string
      * @return Returns the pointer to the location where the sub-string was
      * found, else returns 0
      */
    static const XMLCh* findAny
    (
        const   XMLCh* const    toSearch
        , const XMLCh* const    searchList
    );

    /** Tells if a string has any occurance of another string within itself
      * @param toSearch The string to be searched
      * @param searchList The sub-string to be searched within the string
      * @return Returns the pointer to the location where the sub-string was
      * found, else returns 0
      */
    static XMLCh* findAny
    (
                XMLCh* const    toSearch
        , const XMLCh* const    searchList
    );

    /** Get the length of the string
      * @param src The string whose length is to be determined
      * @return Returns the length of the string
      */
    static unsigned int stringLen(const char* const src);

    /** Get the length of the string
      * @param src The string whose length is to be determined
      * @return Returns the length of the string
      */
    static unsigned int stringLen(const XMLCh* const src);
    //@}

    /** @name Conversion functions */
    //@{

    /** Cut leading chars from a string
      *
      * @param toCut The string to cut chars from
      * @param count The count of leading chars to cut
      */
    static void cut
    (
                XMLCh* const    toCutFrom
        , const unsigned int    count
    );

    /** Transcodes a string to native code-page
      *
      * NOTE: The returned buffer is dynamically allocated and is the 
      * responsibility of the caller to delete it when not longer needed.
      *
      * @param toTranscode The string to be transcoded
      * @return Returns the transcoded string
      */
    static char* transcode
    (
        const   XMLCh* const    toTranscode
    );

    /** Transcodes a string to native code-page
      *
      * Be aware that when transcoding to an external encoding, that each
      * Unicode char can create multiple output bytes. So you cannot assume
      * a one to one correspondence of input chars to output bytes.
      *
      * @param toTranscode The string tobe transcoded
      * @param toFill The buffer that is filled with the transcoded value.
      *        The size of this buffer should atleast be 'maxChars + 1'.
      * @param maxChars The maximum number of bytes that the output
      *         buffer can hold (not including the null, which is why
      *         toFill should be at least maxChars+1.) If the resulting
      *         output cannot fit into this many bytes, it is an error and
      *         false is returned.
      * @return Returns true if successful, false if there was an error
      */
    static bool transcode
    (
        const   XMLCh* const    toTranscode
        ,       char* const     toFill
        , const unsigned int    maxChars
    );

    /** Transcodes a string to native code-page
      *
      * NOTE: The returned buffer is dynamically allocated and is the 
      * responsibility of the caller to delete it when not longer needed.
      *
      * @param toTranscode The string to be transcoded
      * @return Returns the transcoded string
      */
    static XMLCh* transcode
    (
        const   char* const     toTranscode
    );

    /** Transcodes a string to native code-page
      * @param toTranscode The string tobe transcoded
      * @param toFill The buffer that is filled with the transcoded value.
      *        The size of this buffer should atleast be 'maxChars + 1'.
      * @param maxChars The maximum number of characters that the output
      *         buffer can hold (not including the null, which is why
      *         toFill should be at least maxChars+1.) If the resulting
      *         output cannot fit into this many characters, it is an error
      *         and false is returned.
      * @return Returns true if successful, false if there was an error
      */
    static bool transcode
    (
        const   char* const     toTranscode
        ,       XMLCh* const    toFill
        , const unsigned int    maxChars
    );

    /** Trims off extra space characters from the end of the string
      * @param toTrim The string to be trimmed. On return this contains the
      * trimmed string
      */
    static void trim(char* const toTrim);

    /** Trims off extra space characters from the end of the string
      * @param toTrim The string to be trimmed. On return this contains
      * the trimmed string
      */
    static void trim(XMLCh* const toTrim);
    //@}

    /** @name Formatting functions */
    //@{
    /** Creates a UName from a URI and base name. It is in the form
      * {url}name, and is commonly used internally to represent fully
      * qualified names when namespaces are enabled.
      *
      * @param pszURI The URI part of the name
      * @param pszName The base part of the name
      * @return Returns the complete formatted UName
      */
    static XMLCh* makeUName
    (
        const   XMLCh* const    pszURI
        , const XMLCh* const    pszName
    );

    /**
      * Internal function to perform token replacement for strings.
      *
      * @param errText The text (NULL terminated) where the replacement
      *        is to be done. The size of this buffer should be
      *        'maxChars + 1' to account for the final NULL.
      * @param maxChars The size of the output buffer, i.e. the maximum
      *         number of characters that it will hold. If the result is
      *         larger, it will be truncated.
      * @param text1 Replacement text-one
      * @param text2 Replacement text-two
      * @param text3 Replacement text-three
      * @param text4 Replacement text-four
      * @return Returns the count of characters that are outputted
      */
    static unsigned int replaceTokens
    (
                XMLCh* const    errText
        , const unsigned int    maxChars
        , const XMLCh* const    text1
        , const XMLCh* const    text2
        , const XMLCh* const    text3
        , const XMLCh* const    text4
    );

    /** Converts a string to uppercase
      * @param toUpperCase The string which needs to be converted to uppercase.
      *        On return, this buffer also holds the converted uppercase string
      */
    static void upperCase(XMLCh* const toUpperCase);
    //@}


private :
    
    /** @name Constructors and Destructor */
    //@{
    /** Unimplemented default constructor */
    XMLString();
    /** Unimplemented destructor */
    ~XMLString();
    //@}


    /** @name Initialization */
    //@{
    /** Init/Term methods called from XMLPlatformUtils class */
    static void initString(XMLLCPTranscoder* const defToUse);
    static void termString();
    //@}
    friend class XMLPlatformUtils;
};


// ---------------------------------------------------------------------------
//  Inline some methods that are either just passthroughs to other string
//  methods, or which are key for performance.
// ---------------------------------------------------------------------------
inline void XMLString::moveChars(       XMLCh* const    targetStr
                                , const XMLCh* const    srcStr
                                , const unsigned int    count)
{
    XMLCh* outPtr = targetStr;
    const XMLCh* inPtr = srcStr;
    for (unsigned int index = 0; index < count; index++)
        *outPtr++ = *inPtr++;
}

inline unsigned int XMLString::stringLen(const XMLCh* const src)
{
    unsigned int len = 0;
    if (src)
    {
        const XMLCh* pszTmp = src;
        while (*pszTmp++)
            len++;
    }
    return len;
}

inline bool XMLString::startsWith(  const   XMLCh* const    toTest
                                    , const XMLCh* const    prefix)
{
    return (compareNString(toTest, prefix, stringLen(prefix)) == 0);
}

inline bool XMLString::startsWithI( const   XMLCh* const    toTest
                                    , const XMLCh* const    prefix)
{
    return (compareNIString(toTest, prefix, stringLen(prefix)) == 0);
}

inline XMLCh* XMLString::replicate(const XMLCh* const toRep)
{
    // If a null string, return a null string!
    XMLCh* ret = 0;
    if (toRep)
    {
        const unsigned int len = stringLen(toRep);
        ret = new XMLCh[len + 1];
        XMLCh* outPtr = ret;
        const XMLCh* inPtr = toRep;
        for (unsigned int index = 0; index <= len; index++)
            *outPtr++ = *inPtr++;
    }
    return ret;
}

#endif
