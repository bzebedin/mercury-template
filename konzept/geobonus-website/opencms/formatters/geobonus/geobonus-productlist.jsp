<%@page pageEncoding="UTF-8" buffer="none" session="false" trimDirectiveWhitespaces="true"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m"   tagdir="/WEB-INF/tags/mercury" %>

<%-- Reusable arrow-up-right icon --%>
<c:set var="arrowSvg"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M7 17 17 7M7 7h10v10"/></svg></c:set>

<m:init-messages>
<cms:formatter var="content" val="value">
<m:setting-defaults>

<c:set var="ade" value="${cms.isEditMode}" />

<section class="element type-gb-productlist products-section${setCssWrapperAll}" aria-label="${fn:escapeXml(value.Title)}"><%----%>
    <div class="wrap"><%----%>

        <div class="products-head" data-reveal><%----%>
            <c:if test="${value.Eyebrow.isSet}">
                <span class="eyebrow"><span class="dot"></span>${value.Eyebrow}</span><%----%>
            </c:if>
            <h2 ${ade ? content.rdfa.Title : ''}>${value.Title}</h2><%----%>
            <c:if test="${value.Claim.isSet}">
                <p class="products-claim"><span class="fade-text">${value.Claim}</span></p><%----%>
            </c:if>
        </div><%----%>

        <div class="products-list" data-reveal><%----%>
            <c:forEach var="product" items="${content.valueList.Product}"><%----%>
                <c:set var="variant" value="${product.value.Variant.isSet ? product.value.Variant : 'digital'}" /><%----%>
                <c:set var="hasLink" value="${product.value.Link.exists and product.value.Link.value.URI.isSet}" /><%----%>
                <c:set var="tag" value="${hasLink ? 'a' : 'div'}" /><%----%>

                <c:choose>
                    <c:when test="${hasLink}">
                        <m:link link="${product.value.Link}" css="product-row product-row--${variant}"><%----%>
                            <span class="product-tag"><span class="dot"></span>${variant eq 'print' ? 'Print' : 'Digital'}</span><%----%>
                            <div class="product-row-main"><%----%>
                                <span class="product-row-name">${product.value.Name}</span><%----%>
                                <c:if test="${product.value.Description.isSet}"><span class="product-row-desc">${product.value.Description}</span></c:if><%----%>
                            </div><%----%>
                            <span class="product-row-arrow">${arrowSvg}</span><%----%>
                        </m:link><%----%>
                    </c:when>
                    <c:otherwise>
                        <div class="product-row product-row--${variant}"><%----%>
                            <span class="product-tag"><span class="dot"></span>${variant eq 'print' ? 'Print' : 'Digital'}</span><%----%>
                            <div class="product-row-main"><%----%>
                                <span class="product-row-name">${product.value.Name}</span><%----%>
                                <c:if test="${product.value.Description.isSet}"><span class="product-row-desc">${product.value.Description}</span></c:if><%----%>
                            </div><%----%>
                            <span class="product-row-arrow">${arrowSvg}</span><%----%>
                        </div><%----%>
                    </c:otherwise>
                </c:choose>
            </c:forEach><%----%>
        </div><%----%>

    </div><%----%>
</section><%----%>

</m:setting-defaults>
</cms:formatter>
</m:init-messages>
